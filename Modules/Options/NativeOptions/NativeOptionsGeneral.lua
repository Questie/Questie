---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type WorldMapButton
local WorldMapButton = QuestieLoader:ImportModule("WorldMapButton")
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type QuestieShutUp
local QuestieShutUp = QuestieLoader:ImportModule("QuestieShutUp")
---@type Sounds
local Sounds = QuestieLoader:ImportModule("Sounds")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type MinimapIcon
local MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
---@type QuestiePartyObjectives
local QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")

QuestieOptionsEngine.tabs.general = { ... }
local optionsDefaults = QuestieOptionsDefaults:Load()

local LSM30 = LibStub("LibSharedMedia-3.0")

local tinsert, tableSort, stringLower = table.insert, table.sort, string.lower

local _GetAnnounceChannels
local _IsAnnounceDisabled
local _GetQuestSoundChoices
local _GetObjectiveSoundChoices
local _GetObjectiveProgressSoundChoices
local _GetSortedOptions

function QuestieOptionsEngine.tabs.general:Initialize()
    return {
        title = "General",
        subtitle = "General Settings",
        order = 0,
        icon = 133736,
        items = {
            questie_header = {
                type = "divider",
                order = 1,
                title = "General Options",
            },
            --social_spacer = QuestieOptionsUtils:Spacer(1.5,nil,"minimal"),
            social_options_group = {
                type = "container",
                order = 2,
                title = "Social Options",
                args = {
                    filterQuestieAnnounce = {
                        type = "toggle",
                        order = 7.1,
                        title = "Questie ShutUp!",
                        description = "Remove all Questie chat messages coming from other players and disable sending your own.",
                        width = "half",
                        get = function () return Questie.db.profile.questieShutUp end,
                        set = function (_, value)
                            Questie.db.profile.questieShutUp = value
                            QuestieShutUp:ToggleFilters(value)
                        end,
                    },
                    questAnnounceChannel = {
                        type = "dropdown",
                        order = 7.2,
                        values = _GetAnnounceChannels,
                        enabled = function() return not Questie.db.profile.questieShutUp end,
                        title = "Channels to announce in",
                        description = "Announce quest updates to other players in your group",
                        get = function() return Questie.db.profile.questAnnounceChannel; end,
                        set = function(_, key)
                            Questie.db.profile.questAnnounceChannel = key
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Channels to announce changed to:", key)
                        end,
                    },
                    printLocalMessages = {
                        type = "toggle",
                        order = 7.3,
                        title = "Announce quest updates to yourself",
                        description = "Questie will print your update messages to chat. Other players will NOT be able to see this.",
                        enabled = function() return not Questie.db.profile.questieShutUp end,
                        width = 2.5,
                        get = function () return Questie.db.profile.questAnnounceLocally end,
                        set = function (_, value)
                            Questie.db.profile.questAnnounceLocally = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Quest announce locally changed to:", value)
                        end,
                    },
                    showPartyQuestObjectives = {
                        type = "toggle",
                        order = 7.35,
                        title = "Show party members' tracked quest objectives",
                        description = "Show tracked quest objectives from party members on the map and minimap, even for quests you don't have or have already completed. Only your tracked quests will show for your party members.",
                        width = 2.5,
                        get = function() return Questie.db.profile.showPartyQuestObjectives end,
                        set = function(_, value)
                            Questie.db.profile.showPartyQuestObjectives = value
                            QuestiePartyObjectives:Update()
                        end,
                    },
                    shareQuestsNearby = {
                        type = "toggle",
                        order = 7.4,
                        title = "Share quest progress with nearby players",
                        description = "Your quest progress will be periodically sent to nearby players. Disabling this doesn't affect sharing progress with party members.",
                        width = 1.7,
                        hidden = true, -- does this even do anything anymore after YELL removed?
                        get = function() return not Questie.db.profile.disableYellComms end,
                        set = function(_, value)
                            Questie.db.profile.disableYellComms = not value
                            if not value then
                                QuestieComms:RemoveAllRemotePlayers()
                            end
                        end,
                    },
                    questAnnounceTypes = {
                        type = "container",
                        order = 7.5,
                        inline = true,
                        title = "Types of updates to announce in chat",
                        disabled = function() return _IsAnnounceDisabled() or Questie.db.profile.questieShutUp; end,
                        args = {
                            questAnnounceItems = {
                                type = "toggle",
                                order = 1,
                                title = "Items starting a quest",
                                description = "Announce looted items that start a quest to other players",
                                width = 1.5,
                                get = function() return Questie.db.profile.questAnnounceItems; end,
                                set = function(_, value)
                                    Questie.db.profile.questAnnounceItems = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Items starting a quest changed to:", value)
                                end,
                            },
                            questAnnounceAccepted = {
                                type = "toggle",
                                order = 2,
                                title = "Quest accepted",
                                description = "Announce quest acceptance to other players",
                                width = 1.5,
                                get = function() return Questie.db.profile.questAnnounceAccepted; end,
                                set = function(_, value)
                                    Questie.db.profile.questAnnounceAccepted = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest accepted announce changed to:", value)
                                end,
                            },
                            questAnnounceAbandoned = {
                                type = "toggle",
                                order = 3,
                                title = "Quest abandoned",
                                description = "Announce quest abortion to other players",
                                width = 1.5,
                                get = function() return Questie.db.profile.questAnnounceAbandoned; end,
                                set = function(_, value)
                                    Questie.db.profile.questAnnounceAbandoned = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest abandoned announce changed to:", value)
                                end,
                            },
                            questAnnounceObjectives = {
                                type = "toggle",
                                order = 4,
                                title = "Objective completed",
                                description = "Announce completed objectives to other players",
                                width = 1.5,
                                get = function() return Questie.db.profile.questAnnounceObjectives; end,
                                set = function(_, value)
                                    Questie.db.profile.questAnnounceObjectives = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Objective completed announce changed to:", value)
                                end,
                            },
                            questAnnounceCompleted = {
                                type = "toggle",
                                order = 5,
                                title = "Quest completed",
                                description = "Announce quest completion to other players",
                                width = 1.5,
                                get = function() return Questie.db.profile.questAnnounceCompleted; end,
                                set = function(_, value)
                                    Questie.db.profile.questAnnounceCompleted = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest completed announce changed to:", value)
                                end,
                            },
                            questAnnounceIncompleteBreadcrumb = {
                                type = "toggle",
                                order = 6,
                                title = "Incomplete breadcrumb",
                                description = "Announce that you just picked up a quest for which you have an incomplete breadcrumb quest",
                                width = 1.5,
                                get = function() return Questie.db.profile.questAnnounceIncompleteBreadcrumb; end,
                                set = function(_, value)
                                    Questie.db.profile.questAnnounceIncompleteBreadcrumb = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest announce incomplete breadcrumb changed to:", value)
                                end,
                            },
                        },
                    },
                },
            },
            interface_spacer = QuestieOptionsUtils:Spacer(2.5, nil, "minimal"),
            interface_options_group = {
                type = "container",
                order = 3,
                inline = true,
                title = "Interface Options",
                args = {
                    instantQuest = {
                        type = "toggle",
                        order = 5.1,
                        title = "Enable Instant Quest Text",
                        description = "Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface.",
                        width = 1.55,
                        get = function()
                            if GetCVar("instantQuestText") == "1" then
                                return true;
                            else
                                return false;
                            end
                        end,
                        set = function(_, value)
                            if value then
                                SetCVar("instantQuestText", 1);
                            else
                                SetCVar("instantQuestText", 0);
                            end
                        end,
                    },
                    showCustomQuestFrameIcons = {
                        type = "toggle",
                        order = 5.2,
                        title = "Show custom quest frame icons",
                        description = "Use custom Questie icons for NPC dialogs, reflecting the status and type of each quest.",
                        width = 1.55,
                        get = function() return Questie.db.profile.enableQuestFrameIcons; end,
                        set = function(_, value)
                            Questie.db.profile.enableQuestFrameIcons = value
                        end,
                    },
                    mapShowHideEnabled = {
                        type = "toggle",
                        order = 5.25,
                        title = "Show Questie Map Button",
                        description = "Enable or disable the Show/Hide Questie Button on Map (May fix some Map Addon interactions).",
                        width = 1.55,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function(info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            WorldMapButton.Toggle(value)
                        end,
                    },
                    minimapButtonEnabled = {
                        type = "toggle",
                        order = 5.3,
                        title = "Enable Minimap Button",
                        description = "Enable or disable the Questie minimap button. You can still access the options menu with /questie.",
                        width = 1.55,
                        get = function() return not Questie.db.profile.minimap.hide; end,
                        set = function(_, value)
                            MinimapIcon.Toggle(value)
                        end,
                    },
                    mapCoordinatesEnabled = {
                        type = "toggle",
                        order = 5.4,
                        title = "Show Map Coordinates",
                        description = "Place the Player's coordinates and Cursor's coordinates on the Map's title.",
                        width = 1.55,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function(info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            if not value then
                                QuestieCoords.ResetMapText();
                                QuestieCoords:ResetMiniWorldMapText();
                            end
                        end,
                    },
                    minimapCoordinatesEnabled = {
                        type = "toggle",
                        order = 5.5,
                        title = "Show Minimap Coordinates",
                        description = "Place the Player's coordinates on the Minimap title.",
                        width = 1.55,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function(info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            if not value then
                                QuestieCoords:ResetMinimapText();
                            end
                        end,
                    },
                    mapCoordinatePrecision = {
                        type = "range",
                        order = 5.6,
                        title = "Map Coordinates Decimal Precision",
                        description = "How many decimals to include in the precision on the Map for Player and Cursor coordinates.\n(Default: %s)", optionsDefaults.profile.mapCoordinatePrecision,
                        width = 1.4,
                        min = 0,
                        max = 5,
                        step = 1,
                        disabled = function() return not Questie.db.profile.mapCoordinatesEnabled end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function(info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                },
            },
            level_spacer = QuestieOptionsUtils:Spacer(3.5, nil, "minimal"),
            level_options_group = {
                type = "container",
                order = 4,
                inline = true,
                title = "Quest Level Options",
                args = {
                    level_text = {
                        type = "description",
                        order = 1,
                        title = function()
                            return Questie:Colorize(
                                l10n("By default, Questie only shows quests that are relevant for your level. You can change this behavior below."), "gray");
                        end,
                        fontSize = "small",
                    },
                    level_spacer = QuestieOptionsUtils:Spacer(2),
                    radio = {
                        order = 3.0,
                        type = "select",
                        style = "radio",
                        width = 3,
                        title = function() return l10n("Which available quests should be displayed") end,
                        values = function()
                            return {
                                [Questie.LOWLEVEL_NONE] = l10n("Show only quests granting experience (Default)"),
                                [Questie.LOWLEVEL_ALL] = l10n("Show all low level quests"),
                                [Questie.LOWLEVEL_OFFSET] = l10n("Show quests to a set level below the player"),
                                [Questie.LOWLEVEL_RANGE] = l10n("Show quests between two set levels"),
                            }
                        end,
                        get = function() return Questie.db.profile.lowLevelStyle end,
                        set = function(_, value)
                            Questie.db.profile.lowLevelStyle = value
                            AvailableQuests.ResetLevelRequirementCache()
                            AvailableQuests.CalculateAndDrawAll()
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Lowlevel Quests set to:", value)
                        end,
                    },
                    manualOffset = {
                        type = "range",
                        order = 3.1,
                        title = "Player level offset",
                        description = function()
                            return l10n("How many levels below your character to show. (Default: %s)", optionsDefaults.profile.manualLevelOffset);
                        end,
                        width = 1.063,
                        min = 0,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        disabled = function() return (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_OFFSET) end,
                        get = function() return Questie.db.profile.manualLevelOffset end,
                        set = function(_, value)
                            Questie.db.profile.manualLevelOffset = value;
                            QuestieOptionsUtils:Delay(0.3, function()
                                AvailableQuests.ResetLevelRequirementCache()
                                AvailableQuests.CalculateAndDrawAll()
                            end, "manualLevelOffset set to " .. value)
                        end,
                    },
                    minLevelFilter = {
                        type = "range",
                        order = 3.2,
                        title = "Level from",
                        description = "Minimum quest level to show.",
                        width = 1.063,
                        min = 1,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        disabled = function() return (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_RANGE) end,
                        get = function() return Questie.db.profile.minLevelFilter; end,
                        set = function(info, value)
                            if value > Questie.db.profile.maxLevelFilter then
                                value = Questie.db.profile.maxLevelFilter
                            end
                            Questie.db.profile.minLevelFilter = value;
                            QuestieOptionsUtils:Delay(0.3, function()
                                AvailableQuests.ResetLevelRequirementCache()
                                AvailableQuests.CalculateAndDrawAll()
                            end, "minLevelFilter set to " .. value)
                        end,
                    },
                    maxLevelFilter = {
                        type = "range",
                        order = 3.3,
                        title = function()
                            return l10n("Level to");
                        end,
                        description = function()
                            return l10n("Maximum quest level to show.");
                        end,
                        width = 1.063,
                        min = 1,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        disabled = function() return (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_RANGE) end,
                        get = function(_) return Questie.db.profile.maxLevelFilter; end,
                        set = function(_, value)
                            if value < Questie.db.profile.minLevelFilter then
                                value = Questie.db.profile.minLevelFilter
                            end
                            Questie.db.profile.maxLevelFilter = value;
                            QuestieOptionsUtils:Delay(0.3, function()
                                AvailableQuests.ResetLevelRequirementCache()
                                AvailableQuests.CalculateAndDrawAll()
                            end, "maxLevelFilter set to " .. value)
                        end,
                    },
                },
            },
            tooltip_spacer = QuestieOptionsUtils:Spacer(4.5, nil, "minimal"),
            tooltip_options_group = {
                type = "container",
                order = 5,
                inline = true,
                title = "Tooltip Options",
                args = {
                    enableTooltipsToggle = {
                        type = "toggle",
                        order = 8.1,
                        title = "Enable World Tooltips",
                        description = "If checked, quest info will be added to relevant mob/item tooltips.",
                        width = 1.5,
                        get = function() return Questie.db.profile.enableTooltips; end,
                        set = function(_, value) Questie.db.profile.enableTooltips = value end
                    },
                    questsInNpcTooltip = {
                        type = "toggle",
                        order = 8.2,
                        title = "Show quests in NPC tooltips",
                        description = "Show quests (available/complete) in the NPC tooltips.",
                        width = 1.5,
                        disabled = function() return not Questie.db.profile.enableTooltips; end,
                        get = function() return Questie.db.profile.showQuestsInNpcTooltip; end,
                        set = function(_, value) Questie.db.profile.showQuestsInNpcTooltip = value end
                    },
                    showQuestLevels = {
                        type = "toggle",
                        order = 8.3,
                        title = "Show quest level in tooltips",
                        description = "If checked, the level of quests will show in the tooltips.",
                        width = 1.5,
                        get = function() return Questie.db.profile.enableTooltipsQuestLevel; end,
                        set = function(_, value)
                            Questie.db.profile.enableTooltipsQuestLevel = value
                            if value and not Questie.db.profile.trackerShowQuestLevel then
                                Questie.db.profile.trackerShowQuestLevel = true
                                QuestieTracker:Update()
                            end
                        end
                    },
                    questXpAtMaxLevel = {
                        type = "toggle",
                        order = 8.4,
                        title = "Show quest XP at max level",
                        description = "Shows the quest XP values on quests even at max level.",
                        width = 1.5,
                        get = function() return Questie.db.profile.showQuestXpAtMaxLevel; end,
                        set = function(_, value) Questie.db.profile.showQuestXpAtMaxLevel = value end
                    },
                    showNextInChain = {
                        type = "toggle",
                        order = 8.5,
                        title = "Show next quests in chain",
                        description = "If checked, the next quests in the chain will show in the expanded map tooltips.",
                        width = 1.5,
                        get = function() return Questie.db.profile.enableTooltipsNextInChain; end,
                        set = function(_, value)
                            Questie.db.profile.enableTooltipsNextInChain = value
                        end
                    },
                    showBreadcrumbQuests = {
                        type = "toggle",
                        order = 8.51,
                        title = "Show breadcrumb quests",
                        description = "If checked, breadcrumb quests will show in the expanded map tooltips.",
                        width = 1.5,
                        get = function() return Questie.db.profile.enableTooltipsBreadcrumbQuests; end,
                        set = function(_, value)
                            Questie.db.profile.enableTooltipsBreadcrumbQuests = value
                        end
                    },
                    showDropRates = {
                        type = "toggle",
                        order = 8.6,
                        title = "Show item drop rates",
                        description = "If checked, drop rates for quest objectives will show on mob tooltips.",
                        width = 1.5,
                        get = function() return Questie.db.profile.enableTooltipDroprates; end,
                        set = function(_, value)
                            Questie.db.profile.enableTooltipDroprates = value
                        end
                    },
                    partyOnlyToggle = {
                        type = "toggle",
                        order = 8.76,
                        title = "Only show party members",
                        description = "If checked, shared quest info will only show players in your party.",
                        width = 1.5,
                        hidden = true, -- does this even do anything anymore after YELL removed?
                        get = function() return Questie.db.profile.onlyPartyShared; end,
                        set = function(_, value) Questie.db.profile.onlyPartyShared = value end
                    },
                    trimObjectiveText = {
                        type = "toggle",
                        order = 8.8,
                        title = "Trim Objective Text",
                        description = "Simplify quest objective text by removing \"slain\" from it.",
                        width = 1.5,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function(info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieTracker:Update()
                        end,
                    },
                },
            },
            sound_spacer = QuestieOptionsUtils:Spacer(5.5, nil, "minimal"),
            sound_options_group = {
                type = "container",
                order = 6,
                inline = true,
                title = "Sound Options",
                args = {
                    loadCustomSounds = {
                        type = "toggle",
                        order = 8.7,
                        title = "Load custom sounds",
                        description = "If checked, sounds added through LibSharedMedia are loaded.",
                        width = 2.5,
                        get = function() return Questie.db.profile.loadCustomSounds; end,
                        set = function(_, value) Questie.db.profile.loadCustomSounds = value end
                    },
                    soundChannel = {
                        type = "select",
                        order = 8.6,
                        values = function()
                            return {
                                Master = MASTER_VOLUME,
                                Music = MUSIC_VOLUME,
                                SFX = FX_VOLUME,
                                Ambience = AMBIENCE_VOLUME,
                                Dialog = DIALOG_VOLUME,
                            }
                        end,
                        sorting = {"Master", "Music", "SFX", "Ambience", "Dialog"},
                        style = "dropdown",
                        title = function() return l10n("Sound Channel") end,
                        description = function() return l10n("The sound channel used for Questie's notification sounds.") end,
                        get = function() return Questie.db.profile.soundChannel or "Master" end,
                        set = function(_, value)
                            Questie.db.profile.soundChannel = value
                        end,
                    },
                    questCompleteSound = {
                        type = "toggle",
                        order = 9.01,
                        title = "Quest completed",
                        description = "Play a short sound when completing a quest when it is ready to turn in.",
                        width = 1.2,
                        get = function() return Questie.db.profile.soundOnQuestComplete; end,
                        set = function(_, value)
                            Questie.db.profile.soundOnQuestComplete = value
                        end,
                    },
                    questCompleteSoundButton = {
                        type = "execute",
                        order = 9.02,
                        title = "",
                        width = 0.5,
                        image = function()
                            return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                        end,
                        func = function()
                            PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel)
                        end
                    },
                    questCompleteSoundChoice = {
                        type = "select",
                        order = 9.03,
                        values = _GetQuestSoundChoices,
                        sorting = _GetSortedOptions(_GetQuestSoundChoices),
                        style = "dropdown",
                        title = function() return l10n("Quest Complete Sound Selection") end,
                        description = "The sound you hear when a quest is completed",
                        get = function() return Questie.db.profile.questCompleteSoundChoiceName or "None"; end,
                        disabled = function() return (not Questie.db.profile.soundOnQuestComplete); end,
                        set = function(_, value)
                            Questie.db.profile.questCompleteSoundChoicetitle = value
                        end,
                    },
                    soundLineBreak = {
                        type = "description",
                        title = " ",
                        width = 0.1,
                        order = 9.04,
                    },
                    objectiveCompleteSound = {
                        type = "toggle",
                        order = 9.05,
                        title = "Quest objective completed",
                        description = "Play a short sound when completing a quest objective.",
                        width = 1.2,
                        get = function() return Questie.db.profile.soundOnObjectiveComplete; end,
                        set = function(_, value)
                            Questie.db.profile.soundOnObjectiveComplete = value
                        end,
                    },
                    objectiveCompleteSoundButton = {
                        type = "execute",
                        order = 9.06,
                        title = "",
                        width = 0.5,
                        image = function()
                            return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                        end,
                        func = function()
                            PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveCompleteSoundChoiceName), Questie.db.profile.soundChannel)
                        end
                    },
                    objectiveCompleteSoundChoice = {
                        type = "select",
                        order = 9.07,
                        values = _GetObjectiveSoundChoices,
                        sorting = _GetSortedOptions(_GetObjectiveSoundChoices),
                        style = "dropdown",
                        title = function() return l10n("Objective Complete Sound Selection") end,
                        description = "The sound you hear when an objective is completed",
                        get = function() return Questie.db.profile.objectiveCompleteSoundChoiceName; end,
                        disabled = function() return (not Questie.db.profile.soundOnObjectiveComplete); end,
                        set = function(_, value)
                            Questie.db.profile.objectiveCompleteSoundChoicetitle = value
                        end,
                    },
                    objectiveProgressSound = {
                        type = "toggle",
                        order = 9.08,
                        title = "Quest objective progress",
                        description = "Play a short sound when making progress on a quest objective.",
                        width = 1.2,
                        get = function() return Questie.db.profile.soundOnObjectiveProgress; end,
                        set = function(_, value)
                            Questie.db.profile.soundOnObjectiveProgress = value
                        end,
                    },
                    objectiveProgressSoundButton = {
                        type = "execute",
                        order = 9.09,
                        title = "",
                        width = 0.5,
                        image = function()
                            return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                        end,
                        func = function()
                            PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveProgressSoundChoiceName), Questie.db.profile.soundChannel)
                        end
                    },
                    objectiveProgressSoundChoice = {
                        type = "select",
                        order = 9.10,
                        values = _GetObjectiveProgressSoundChoices,
                        sorting = _GetSortedOptions(_GetObjectiveProgressSoundChoices),
                        style = "dropdown",
                        title = function() return l10n("Objective Progress Sound Selection") end,
                        description = "The sound you hear when you make progress on a quest objective",
                        get = function() return Questie.db.profile.objectiveProgressSoundChoiceName; end,
                        disabled = function() return (not Questie.db.profile.soundOnObjectiveProgress); end,
                        set = function(_, value)
                            Questie.db.profile.objectiveProgressSoundChoicetitle = value
                        end,
                    },
                    soundDelay = {
                        type = "range",
                        order = 10.0,
                        title = "Progress Sound Delay",
                        description = function()
                            return l10n(
                                "Delay (in seconds, default: %s) for playing objective progress and completion sounds. Increase this if you hear double sounds.",
                                optionsDefaults.profile.soundDelay);
                        end,
                        width = 1.4,
                        min = 0.0,
                        max = 1.0,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                },
            },
        },
    }
end

_GetAnnounceChannels = function()
    return {
        ["disabled"] = l10n("Disabled"),
        ["party"] = l10n("Party"),
        ["raid"] = l10n("Raid"),
        ["both"] = l10n("Both"),
    }
end

---@return boolean
_IsAnnounceDisabled = function()
    return (not Questie.db.profile.questAnnounceChannel) or (Questie.db.profile.questAnnounceChannel == "disabled")
end

_GetQuestSoundChoices = function()
    local options = {
        ["QuestDefault"]     = DEFAULT,
        ["GameDefault"]      = l10n("Game Default"),
        ["Troll Male"]       = l10n("Troll Male"),
        ["Troll Female"]     = l10n("Troll Female"),
        ["Tauren Male"]      = l10n("Tauren Male"),
        ["Tauren Female"]    = l10n("Tauren Female"),
        ["Undead Male"]      = l10n("Undead Male"),
        ["Undead Female"]    = l10n("Undead Female"),
        ["Orc Male"]         = l10n("Orc Male"),
        ["Orc Female"]       = l10n("Orc Female"),
        ["Night Elf Male"]   = l10n("Night Elf Male"),
        ["Night Elf Female"] = l10n("Night Elf Female"),
        ["Human Male"]       = l10n("Human Male"),
        ["Human Female"]     = l10n("Human Female"),
        ["Gnome Male"]       = l10n("Gnome Male"),
        ["Gnome Female"]     = l10n("Gnome Female"),
        ["Dwarf Male"]       = l10n("Dwarf Male"),
        ["Dwarf Female"]     = l10n("Dwarf Female"),
        ["Zug Zug"]          = l10n("Zug Zug"),
    }

    if Expansions.Current >= Expansions.Tbc or Questie.IsForever then
        options["Draenei Male"]     = l10n("Draenei Male")
        options["Draenei Female"]   = l10n("Draenei Female")
        options["Blood Elf Male"]   = l10n("Blood Elf Male")
        options["Blood Elf Female"] = l10n("Blood Elf Female")
    end

    if Expansions.Current >= Expansions.Cata or Questie.IsForever then
        options["Goblin Male"]    = l10n("Goblin Male")
        options["Goblin Female"]  = l10n("Goblin Female")
        options["Worgen Male"]    = l10n("Worgen Male")
        options["Worgen Female"]  = l10n("Worgen Female")
        options["Gilnean Male"]   = l10n("Gilnean Male")
        options["Gilnean Female"] = l10n("Gilnean Female")
    end

    if Expansions.Current >= Expansions.MoP or Questie.IsForever then
        options["Pandaren Male"]    = l10n("Pandaren Male")
        options["Pandaren Female"]  = l10n("Pandaren Female")
    end

    if Questie.db.profile.loadCustomSounds then
        for _, sound in pairs(LSM30:List(LSM30.MediaType.SOUND)) do
            options[sound] = sound
        end
    end

    return options
end

_GetObjectiveSoundChoices = function()
    local options = {
        ["ObjectiveDefault"]   = DEFAULT,
        ["Map Ping"]           = l10n("Map Ping"),
        ["Window Close"]       = l10n("Window Close"),
        ["Window Open"]        = l10n("Window Open"),
        ["Boat Docked"]        = l10n("Boat Docked"),
        ["Bell Toll Alliance"] = l10n("Bell Toll Alliance"),
        ["Bell Toll Horde"]    = l10n("Bell Toll Horde"),
    }
    if Expansions.Current >= Expansions.Tbc or Questie.IsForever then
        options["Explosion"] = l10n("Explosion")
        options["Shing!"] = l10n("Shing!")
        options["Wham!"] = l10n("Wham!")
        options["Simon Chime"] = l10n("Simon Chime")
        options["War Drums"] = l10n("War Drums")
        options["Humm"] = l10n("Humm")
        options["Short Circuit"] = l10n("Short Circuit")
    end

    if Questie.db.profile.loadCustomSounds then
        for _, sound in pairs(LSM30:List(LSM30.MediaType.SOUND)) do
            options[sound] = sound
        end
    end

    return options
end

_GetObjectiveProgressSoundChoices = function()
    local options = {
        ["ObjectiveProgress"]  = DEFAULT,
        ["ObjectiveDefault"]   = l10n("Objective Complete"),
        ["Map Ping"]           = l10n("Map Ping"),
        ["Window Close"]       = l10n("Window Close"),
        ["Window Open"]        = l10n("Window Open"),
        ["Boat Docked"]        = l10n("Boat Docked"),
        ["Bell Toll Alliance"] = l10n("Bell Toll Alliance"),
        ["Bell Toll Horde"]    = l10n("Bell Toll Horde"),
    }
    if Expansions.Current >= Expansions.Tbc or Questie.IsForever then
        options["Explosion"] = l10n("Explosion")
        options["Shing!"] = l10n("Shing!")
        options["Wham!"] = l10n("Wham!")
        options["Simon Chime"] = l10n("Simon Chime")
        options["War Drums"] = l10n("War Drums")
        options["Humm"] = l10n("Humm")
        options["Short Circuit"] = l10n("Short Circuit")
    end

    if Questie.db.profile.loadCustomSounds then
        for _, sound in pairs(LSM30:List(LSM30.MediaType.SOUND)) do
            options[sound] = sound
        end
    end

    return options
end

---Sorts options alphabetically, ignoring case.
---We return a function to allow ace to refetch the options.
---@param getOptions function
---@return function
_GetSortedOptions = function(getOptions)
    return function()
        local sorting = {}
        for key, value in pairs(getOptions()) do
            tinsert(sorting, {key = key, value = value})
        end
        tableSort(sorting, function(a, b)
            return stringLower(a.value) < stringLower(b.value)
        end)
        local sortedKeys = {}
        for _, pair in ipairs(sorting) do
            tinsert(sortedKeys, pair.key)
        end
        return sortedKeys
    end
end
