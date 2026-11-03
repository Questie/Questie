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
        subtitle = "General Options",
        order = 0,
        icon = 134331,
        items = {
            --questie_header = {
            --    type = "divider",
            --    order = 1,
            --    title = "General Options",
            --},
            social_options_group = {
                type = "container",
                order = 2,
                title = "Social Options",
                items = {
                    filterQuestieAnnounce = {
                        type = "checkbox",
                        order = 7.1,
                        title = "Questie ShutUp!",
                        description = "Remove all Questie chat messages coming from other players and disable sending your own.",
                        width = 0.6,
                        get = function () return Questie.db.profile.questieShutUp end,
                        set = function (info, value)
                            Questie.db.profile.questieShutUp = value
                            QuestieShutUp:ToggleFilters(value)
                        end,
                    },
                    questAnnounceChannel = {
                        type = "dropdown",
                        order = 7.2,
                        options = _GetAnnounceChannels(),
                        enabled = function() return not Questie.db.profile.questieShutUp end,
                        title = "Channels to announce in",
                        tooltip = "Announce quest updates to other players in your group",
                        width = 0.39,
                        get = function() return Questie.db.profile.questAnnounceChannel; end,
                        set = function(key)
                            Questie.db.profile.questAnnounceChannel = key
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Channels to announce changed to:", key)
                        end,
                    },
                    printLocalMessages = {
                        type = "checkbox",
                        order = 7.3,
                        title = "Announce quest updates to yourself",
                        tooltip = "Questie will print your update messages to chat. Other players will NOT be able to see this.",
                        enabled = function() return not Questie.db.profile.questieShutUp end,
                        width = "full",
                        get = function () return Questie.db.profile.questAnnounceLocally end,
                        set = function (info, value)
                            Questie.db.profile.questAnnounceLocally = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Quest announce locally changed to:", value)
                        end,
                    },
                    showPartyQuestObjectives = {
                        type = "checkbox",
                        order = 7.35,
                        title = "Show party members' tracked quest objectives",
                        tooltip = "Show tracked quest objectives from party members on the map and minimap, even for quests you don't have or have already completed. Only your tracked quests will show for your party members.",
                        width = "full",
                        get = function() return Questie.db.profile.showPartyQuestObjectives end,
                        set = function(info, value)
                            Questie.db.profile.showPartyQuestObjectives = value
                            QuestiePartyObjectives:Update()
                        end,
                    },
                    questAnnounceTypes = {
                        type = "container",
                        order = 7.5,
                        inline = true,
                        title = "Types of updates to announce in chat",
                        enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                        items = {
                            questAnnounceItems = {
                                type = "checkbox",
                                order = 1,
                                title = "Items starting a quest",
                                tooltip = "Announce looted items that start a quest to other players",
                                width = "half",
                                enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                                get = function() return Questie.db.profile.questAnnounceItems; end,
                                set = function(info, value)
                                    Questie.db.profile.questAnnounceItems = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Items starting a quest changed to:", value)
                                end,
                            },
                            questAnnounceAccepted = {
                                type = "checkbox",
                                order = 2,
                                title = "Quest accepted",
                                tooltip = "Announce quest acceptance to other players",
                                width = "half",
                                enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                                get = function() return Questie.db.profile.questAnnounceAccepted; end,
                                set = function(info, value)
                                    Questie.db.profile.questAnnounceAccepted = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest accepted announce changed to:", value)
                                end,
                            },
                            questAnnounceAbandoned = {
                                type = "checkbox",
                                order = 3,
                                title = "Quest abandoned",
                                tooltip = "Announce quest abortion to other players",
                                width = "half",
                                enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                                get = function() return Questie.db.profile.questAnnounceAbandoned; end,
                                set = function(info, value)
                                    Questie.db.profile.questAnnounceAbandoned = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest abandoned announce changed to:", value)
                                end,
                            },
                            questAnnounceObjectives = {
                                type = "checkbox",
                                order = 4,
                                title = "Objective completed",
                                tooltip = "Announce completed objectives to other players",
                                width = "half",
                                enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                                get = function() return Questie.db.profile.questAnnounceObjectives; end,
                                set = function(info, value)
                                    Questie.db.profile.questAnnounceObjectives = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Objective completed announce changed to:", value)
                                end,
                            },
                            questAnnounceCompleted = {
                                type = "checkbox",
                                order = 5,
                                title = "Quest completed",
                                tooltip = "Announce quest completion to other players",
                                width = "half",
                                enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                                get = function() return Questie.db.profile.questAnnounceCompleted; end,
                                set = function(info, value)
                                    Questie.db.profile.questAnnounceCompleted = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest completed announce changed to:", value)
                                end,
                            },
                            questAnnounceIncompleteBreadcrumb = {
                                type = "checkbox",
                                order = 6,
                                title = "Incomplete breadcrumb",
                                tooltip = "Announce that you just picked up a quest for which you have an incomplete breadcrumb quest",
                                width = "half",
                                enabled = function() return not (_IsAnnounceDisabled() or Questie.db.profile.questieShutUp); end,
                                get = function() return Questie.db.profile.questAnnounceIncompleteBreadcrumb; end,
                                set = function(info, value)
                                    Questie.db.profile.questAnnounceIncompleteBreadcrumb = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Quest announce incomplete breadcrumb changed to:", value)
                                end,
                            },
                        },
                    },
                },
            },
            interface_options_group = {
                type = "container",
                order = 3,
                title = "Interface Options",
                items = {
                    instantQuest = {
                        type = "checkbox",
                        order = 5.1,
                        title = "Enable Instant Quest Text",
                        tooltip = "Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface.",
                        width = "half",
                        get = function()
                            if GetCVar("instantQuestText") == "1" then
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
                    showCustomQuestFrameIcons = {
                        type = "checkbox",
                        order = 5.2,
                        title = "Show custom quest frame icons",
                        tooltip = "Use custom Questie icons for NPC dialogs, reflecting the status and type of each quest.",
                        width = "half",
                        get = function() return Questie.db.profile.enableQuestFrameIcons; end,
                        set = function(info, value)
                            Questie.db.profile.enableQuestFrameIcons = value
                        end,
                    },
                    mapShowHideEnabled = {
                        type = "checkbox",
                        order = 5.25,
                        title = "Show Questie Map Button",
                        tooltip = "Enable or disable the Show/Hide Questie Button on Map (May fix some Map Addon interactions).",
                        width = "half",
                        get = function(info) return Questie.db.profile.mapShowHideEnabled; end,
                        set = function(info, value)
                            Questie.db.profile.mapShowHideEnabled = value
                            WorldMapButton.Toggle(value)
                        end,
                    },
                    minimapButtonEnabled = {
                        type = "checkbox",
                        order = 5.3,
                        title = "Enable Minimap Button",
                        tooltip = "Enable or disable the Questie minimap button. You can still access the options menu with /questie.",
                        width = "half",
                        get = function() return not Questie.db.profile.minimap.hide; end,
                        set = function(info, value)
                            MinimapIcon.Toggle(value)
                        end,
                    },
                    mapCoordinatesEnabled = {
                        type = "checkbox",
                        order = 5.4,
                        title = "Show Map Coordinates",
                        tooltip = "Place the Player's coordinates and Cursor's coordinates on the Map's title.",
                        width = "half",
                        get = function(info) return Questie.db.profile.mapCoordinatesEnabled; end,
                        set = function(info, value)
                            Questie.db.profile.mapCoordinatesEnabled = value
                            if not value then
                                QuestieCoords.ResetMapText();
                                QuestieCoords:ResetMiniWorldMapText();
                            end
                        end,
                    },
                    minimapCoordinatesEnabled = {
                        type = "checkbox",
                        order = 5.5,
                        title = "Show Minimap Coordinates",
                        tooltip = "Place the Player's coordinates on the Minimap title.",
                        width = "half",
                        get = function(info) return Questie.db.profile.minimapCoordinatesEnabled; end,
                        set = function(info, value)
                            Questie.db.profile.minimapCoordinatesEnabled = value

                            if not value then
                                QuestieCoords:ResetMinimapText();
                            end
                        end,
                    },
                    mapCoordinatePrecision = {
                        type = "slider",
                        order = 5.6,
                        title = "Map Coordinates Decimal Precision",
                        tooltip = {"How many decimals to include in the precision on the Map for Player and Cursor coordinates.\n(Default: %s)", optionsDefaults.profile.mapCoordinatePrecision},
                        width = "half",
                        min = 0,
                        max = 5,
                        step = 1,
                        enabled = function() return Questie.db.profile.mapCoordinatesEnabled end,
                        get = function(info) return Questie.db.profile.mapCoordinatePrecision; end,
                        set = function(info, value)
                            Questie.db.profile.mapCoordinatePrecision = value
                        end,
                    },
                },
            },
            level_options_group = {
                type = "container",
                order = 4,
                title = "Quest Level Options",
                items = {
                    level_text = {
                        order = 1,
                        description = "By default, Questie only shows quests that are relevant for your level. You can change this behavior below.",
                        type = "text",
                        width = "full",
                        descriptionAlign = "LEFT",
                    },
                    level_options_container = {
                        order = 3,
                        title = "Which available quests should be displayed",
                        type = "container", -- containers hold other controls within them, and only show a title labelling the container
                        items = {
                            levelRadio_none = {
                                order = 1,
                                title = "Show only quests granting experience (Default)",
                                type = "radioButton",
                                width = "full",
                                value = Questie.LOWLEVEL_NONE,
                                get = function(value) return Questie.db.profile.lowLevelStyle == value end,
                                set = function(value)
                                    Questie.db.profile.lowLevelStyle = value
                                    AvailableQuests.ResetLevelRequirementCache()
                                    AvailableQuests.CalculateAndDrawAll()
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Lowlevel Quests set to:", value)
                                end,
                            },
                            levelRadio_all = {
                                order = 2,
                                title = "Show all low level quests",
                                type = "radioButton",
                                width = "full",
                                value = Questie.LOWLEVEL_ALL,
                                get = function(value) return Questie.db.profile.lowLevelStyle == value end,
                                set = function(value)
                                    Questie.db.profile.lowLevelStyle = value
                                    AvailableQuests.ResetLevelRequirementCache()
                                    AvailableQuests.CalculateAndDrawAll()
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Lowlevel Quests set to:", value)
                                end,
                            },
                            levelRadio_offset = {
                                order = 3,
                                title = "Show quests to a set level below the player",
                                type = "radioButton",
                                width = "full",
                                value = Questie.LOWLEVEL_OFFSET,
                                get = function(value) return Questie.db.profile.lowLevelStyle == value end,
                                set = function(value)
                                    Questie.db.profile.lowLevelStyle = value
                                    AvailableQuests.ResetLevelRequirementCache()
                                    AvailableQuests.CalculateAndDrawAll()
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Lowlevel Quests set to:", value)
                                end,
                            },
                            levelRadio_range = {
                                order = 4,
                                title = "Show quests between two set levels",
                                type = "radioButton",
                                width = "full",
                                value = Questie.LOWLEVEL_RANGE,
                                get = function(value) return Questie.db.profile.lowLevelStyle == value end,
                                set = function(value)
                                    Questie.db.profile.lowLevelStyle = value
                                    AvailableQuests.ResetLevelRequirementCache()
                                    AvailableQuests.CalculateAndDrawAll()
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Lowlevel Quests set to:", value)
                                end,
                            },
                        },
                    },
                    manualOffset = {
                        type = "slider",
                        order = 3.1,
                        title = "Player level offset",
                        tooltip = {"How many levels below your character to show. (Default: %s)", optionsDefaults.profile.manualLevelOffset},
                        width = "third",
                        min = 0,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        enabled = function() return (Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_OFFSET) end,
                        get = function() return Questie.db.profile.manualLevelOffset end,
                        set = function(info, value)
                            Questie.db.profile.manualLevelOffset = value;
                            QuestieOptionsUtils:Delay(0.3, function()
                                AvailableQuests.ResetLevelRequirementCache()
                                AvailableQuests.CalculateAndDrawAll()
                            end, "manualLevelOffset set to " .. value)
                        end,
                    },
                    minLevelFilter = {
                        type = "slider",
                        order = 3.2,
                        title = "Level from",
                        tooltip = "Minimum quest level to show.",
                        width = "third",
                        min = 1,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        enabled = function() return (Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_RANGE) end,
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
                        type = "slider",
                        order = 3.3,
                        title = "Level to",
                        tooltip = "Maximum quest level to show.",
                        width = "third",
                        min = 1,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        enabled = function() return (Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_RANGE) end,
                        get = function() return Questie.db.profile.maxLevelFilter; end,
                        set = function(info, value)
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
            tooltip_options_group = {
                type = "container",
                order = 5,
                title = "Tooltip Options",
                items = {
                    enableTooltipsToggle = {
                        type = "checkbox",
                        order = 8.1,
                        title = "Enable World Tooltips",
                        tooltip = "If checked, quest info will be added to relevant mob/item tooltips.",
                        width = "half",
                        get = function() return Questie.db.profile.enableTooltips; end,
                        set = function(info, value) Questie.db.profile.enableTooltips = value end
                    },
                    questsInNpcTooltip = {
                        type = "checkbox",
                        order = 8.2,
                        title = "Show quests in NPC tooltips",
                        tooltip = "Show quests (available/complete) in the NPC tooltips.",
                        width = "half",
                        enabled = function() return Questie.db.profile.enableTooltips; end,
                        get = function() return Questie.db.profile.showQuestsInNpcTooltip; end,
                        set = function(info, value) Questie.db.profile.showQuestsInNpcTooltip = value end
                    },
                    showQuestLevels = {
                        type = "checkbox",
                        order = 8.3,
                        title = "Show quest level in tooltips",
                        tooltip = "If checked, the level of quests will show in the tooltips.",
                        width = "half",
                        get = function() return Questie.db.profile.enableTooltipsQuestLevel; end,
                        set = function(info, value)
                            Questie.db.profile.enableTooltipsQuestLevel = value
                            if value and not Questie.db.profile.trackerShowQuestLevel then
                                Questie.db.profile.trackerShowQuestLevel = true
                                QuestieTracker:Update()
                            end
                        end
                    },
                    questXpAtMaxLevel = {
                        type = "checkbox",
                        order = 8.4,
                        title = "Show quest XP at max level",
                        tooltip = "Shows the quest XP values on quests even at max level.",
                        width = "half",
                        get = function() return Questie.db.profile.showQuestXpAtMaxLevel; end,
                        set = function(info, value) Questie.db.profile.showQuestXpAtMaxLevel = value end
                    },
                    showNextInChain = {
                        type = "checkbox",
                        order = 8.5,
                        title = "Show next quests in chain",
                        tooltip = "If checked, the next quests in the chain will show in the expanded map tooltips.",
                        width = "half",
                        get = function() return Questie.db.profile.enableTooltipsNextInChain; end,
                        set = function(info, value)
                            Questie.db.profile.enableTooltipsNextInChain = value
                        end
                    },
                    showBreadcrumbQuests = {
                        type = "checkbox",
                        order = 8.51,
                        title = "Show breadcrumb quests",
                        tooltip = "If checked, breadcrumb quests will show in the expanded map tooltips.",
                        width = "half",
                        get = function() return Questie.db.profile.enableTooltipsBreadcrumbQuests; end,
                        set = function(info, value)
                            Questie.db.profile.enableTooltipsBreadcrumbQuests = value
                        end
                    },
                    showDropRates = {
                        type = "checkbox",
                        order = 8.6,
                        title = "Show item drop rates",
                        tooltip = "If checked, drop rates for quest objectives will show on mob tooltips.",
                        width = "half",
                        get = function() return Questie.db.profile.enableTooltipDroprates; end,
                        set = function(info, value)
                            Questie.db.profile.enableTooltipDroprates = value
                        end
                    },
                },
            },
            sound_options_group = {
                type = "container",
                order = 6,
                title = "Sound Options",
                items = {
                    soundChannel = {
                        type = "dropdown",
                        order = 8.6,
                        width = "half",
                        options = function()
                            return {
                                Master = MASTER_VOLUME,
                                Music = MUSIC_VOLUME,
                                SFX = FX_VOLUME,
                                Ambience = AMBIENCE_VOLUME,
                                Dialog = DIALOG_VOLUME,
                            }
                        end,
                        sortOrder = {"Master", "Music", "SFX", "Ambience", "Dialog"},
                        title = "Sound Channel",
                        tooltip = "The sound channel used for Questie's notification sounds.",
                        get = function() return Questie.db.profile.soundChannel or "Master" end,
                        set = function(value)
                            Questie.db.profile.soundChannel = value
                        end,
                    },
                    loadCustomSounds = {
                        type = "checkbox",
                        order = 8.7,
                        title = "Load custom sounds",
                        tooltip = "If checked, sounds added through LibSharedMedia are loaded.",
                        width = "half",
                        newline = true,
                        get = function() return Questie.db.profile.loadCustomSounds; end,
                        set = function(info, value) Questie.db.profile.loadCustomSounds = value end
                    },
                    questCompleteSound = {
                        type = "checkbox",
                        order = 9.01,
                        title = "Quest completed",
                        tooltip = "Play a short sound when completing a quest when it is ready to turn in.",
                        width = 0.5,
                        newline = true,
                        get = function() return Questie.db.profile.soundOnQuestComplete; end,
                        set = function(info, value)
                            Questie.db.profile.soundOnQuestComplete = value
                        end,
                    },
                    questCompleteSoundButton = {
                        order = 9.02,
                        type = "soundButton",
                        width = 0.08,
                        func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel) end,
                    },
                    questCompleteSoundChoice = {
                        type = "dropdown",
                        order = 9.03,
                        options = _GetQuestSoundChoices,
                        sortOrder = _GetSortedOptions(_GetQuestSoundChoices),
                        title = "Quest Complete Sound Selection",
                        width = 0.4,
                        tooltip = "The sound you hear when a quest is completed",
                        get = function() return Questie.db.profile.questCompleteSoundChoiceName or "None"; end,
                        enabled = function() return (Questie.db.profile.soundOnQuestComplete); end,
                        set = function(value)
                            Questie.db.profile.questCompleteSoundChoiceName = value
                        end,
                    },
                    objectiveCompleteSound = {
                        type = "checkbox",
                        order = 9.05,
                        title = "Quest objective completed",
                        tooltip = "Play a short sound when completing a quest objective.",
                        width = 0.5,
                        newline = true,
                        get = function() return Questie.db.profile.soundOnObjectiveComplete; end,
                        set = function(info, value)
                            Questie.db.profile.soundOnObjectiveComplete = value
                        end,
                    },
                    objectiveCompleteSoundButton = {
                        order = 9.06,
                        type = "soundButton",
                        width = 0.08,
                        func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveCompleteSoundChoiceName), Questie.db.profile.soundChannel) end,
                    },
                    objectiveCompleteSoundChoice = {
                        type = "dropdown",
                        order = 9.07,
                        options = _GetObjectiveSoundChoices,
                        sortOrder = _GetSortedOptions(_GetObjectiveSoundChoices),
                        title = "Objective Complete Sound Selection",
                        width = 0.4,
                        tooltip = "The sound you hear when an objective is completed",
                        get = function() return Questie.db.profile.objectiveCompleteSoundChoiceName; end,
                        enabled = function() return (Questie.db.profile.soundOnObjectiveComplete); end,
                        set = function(value)
                            Questie.db.profile.objectiveCompleteSoundChoiceName = value
                        end,
                    },
                    objectiveProgressSound = {
                        type = "checkbox",
                        order = 9.08,
                        title = "Quest objective progress",
                        tooltip = "Play a short sound when making progress on a quest objective.",
                        width = 0.5,
                        newline = true,
                        get = function() return Questie.db.profile.soundOnObjectiveProgress; end,
                        set = function(info, value)
                            Questie.db.profile.soundOnObjectiveProgress = value
                        end,
                    },
                    objectiveProgressSoundButton = {
                        order = 9.09,
                        type = "soundButton",
                        width = 0.08,
                        func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveProgressSoundChoiceName), Questie.db.profile.soundChannel) end,
                    },
                    objectiveProgressSoundChoice = {
                        type = "dropdown",
                        order = 9.10,
                        options = _GetObjectiveProgressSoundChoices,
                        sortOrder = _GetSortedOptions(_GetObjectiveProgressSoundChoices),
                        title = "Objective Progress Sound Selection",
                        width = 0.4,
                        tooltip = "The sound you hear when you make progress on a quest objective",
                        get = function() return Questie.db.profile.objectiveProgressSoundChoiceName; end,
                        enabled = function() return (Questie.db.profile.soundOnObjectiveProgress); end,
                        set = function(value)
                            Questie.db.profile.objectiveProgressSoundChoiceName = value
                        end,
                    },
                    soundDelay = {
                        type = "slider",
                        order = 10.0,
                        title = "Progress Sound Delay",
                        tooltip = {"Delay (in seconds, default: %s) for playing objective progress and completion sounds. Increase this if you hear double sounds.",
                                optionsDefaults.profile.soundDelay},
                        width = "half",
                        min = 0.0,
                        max = 1.0,
                        step = 0.01,
                        get = function(info) return Questie.db.profile.soundDelay; end,
                        set = function(_, value)
                            Questie.db.profile.soundDelay = value
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
