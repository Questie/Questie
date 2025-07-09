-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

QuestieOptions.tabs.advanced = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()
local _GetLanguages

function QuestieOptions.tabs.advanced:Initialize()
    return {
        name = function() return l10n("Advanced"); end,
        type = "group",
        order = 7,
        args = {
            map_options = {
                type = "header",
                order = 1,
                name = function() return l10n("Advanced Settings"); end,
            },
            hideStartupWarnings = {
                type = "toggle",
                order = 1.05,
                hidden = true, -- TODO: We don"t need that option anymore as the message is gone. But it can be used to hide others in the future
                name = function() return l10n("Hide Startup Warnings"); end,
                desc = function() return l10n("Disables the \"Welcome to Cataclysm Classic\" message on startup."); end,
                width = "full",
                get = function() return Questie.db.profile.hideStartupWarnings; end,
                set = function (_, value)
                    Questie.db.profile.hideStartupWarnings = value
                end
            },
            enableIconLimit = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n("Enable Icon Limit"); end,
                desc = function() return l10n("Enable the limit of icons drawn per type."); end,
                width = "full",
                get = function (info) return QuestieOptions:GetProfileValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetProfileValue(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            iconLimit = {
                type = "range",
                order = 1.2,
                name = function() return l10n("Icon Limit"); end,
                desc = function() return l10n("Limits the amount of icons drawn per type. ( Default: %s )", optionsDefaults.profile.iconLimit); end,
                width = 1.5,
                min = 1,
                max = 5000,
                step = 10,
                disabled = function() return (not Questie.db.profile.enableIconLimit); end,
                get = function(info) return QuestieOptions:GetProfileValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetProfileValue(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            iconSpacer = {
                type = "description",
                order = 1.3,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.3,
                width = 0.3,
                func = function() end,
            },
            clusterLevelHotzone = {
                type = "range",
                order = 1.4,
                name = function() return l10n("Objective icon cluster amount"); end,
                desc = function() return l10n("How much objective icons should cluster."); end,
                width = 1.5,
                disabled = function() return (not Questie.db.profile.enabled); end,
                min = 1,
                max = 300,
                step = 1,
                get = function(info) return QuestieOptions:GetProfileValue(info); end,
                set = function(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieOptions.ClusterRedraw, l10n("Setting clustering value, clusterLevelHotzone set to %s : Redrawing!", value))
                    QuestieOptions:SetProfileValue(info, value)
                    QuestieOptionsUtils.DetermineTheme()
                end,
            },
            spawnFilterDistance = {
                type = "range",
                order = 1.41,
                name = function() return l10n("Available quest filter distance"); end,
                desc = function() return l10n("How far away a spawn starting a quest needs to be inside a zone before another spawn of the same creature or object is added.\n\nWARNING! Setting this to lower values may result in a lot of icons being drawn and can impact map performance!"); end,
                width = 1.5,
                disabled = function() return (not Questie.db.profile.enabled); end,
                min = 1,
                max = 100,
                step = 1,
                get = function(info) return QuestieOptions:GetProfileValue(info); end,
                set = function(info, value)
                    QuestieOptions:SetProfileValue(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            iconSpacer2 = {
                type = "description",
                order = 1.42,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.3,
                width = 0.3,
                func = function() end,
            },
            availableIconLimit = {
                type = "range",
                order = 1.43,
                name = function() return l10n("Available quest icon limit"); end,
                desc = function() return l10n("This setting limits the number of icons starting a single quest.\n\nSetting to zero means there is no limit (except through other settings).\n\nWARNING! Setting this to 0 may result in a lot of icons being drawn and can impact map performance!"); end,
                width = 1.5,
                disabled = function() return (not Questie.db.profile.enabled); end,
                min = 0,
                max = 500,
                step = 1,
                get = function(info) return QuestieOptions:GetProfileValue(info); end,
                set = function(info, value)
                    QuestieOptions:SetProfileValue(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            quelDanasSpacer1 = QuestieOptionsUtils:Spacer(1.45, (not Questie.IsTBC)),
            npcrules_group = {
                type = "group",
                order = 1.5,
                inline = true,
                width = 0.5,
                hidden = (not Questie.IsTBC),
                name = function() return l10n("Quel'Danas Settings"); end,
                disabled = function() return not Questie.db.profile.autoAccept.enabled end,
                args = {
                    isleOfQuelDanasPhase = {
                        type = "select",
                        order = 1.3,
                        width = 1.5,
                        values = IsleOfQuelDanas.localizedPhaseNames,
                        style = "dropdown",
                        name = function() return l10n("Isle of Quel'Danas Phase") end,
                        desc = function() return l10n("Select the phase fitting your realm progress on the Isle of Quel'Danas"); end,
                        disabled = function() return Expansions.Current <= Expansions.Tbc end,
                        get = function() return Questie.db.profile.isleOfQuelDanasPhase; end,
                        set = function(_, key)
                            Questie.db.profile.isleOfQuelDanasPhase = key
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    quelDanasSpacer2 = {
                        type = "description",
                        order = 1.4,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    isleOfQuelDanasPhaseReminder = {
                        type = "toggle",
                        order = 1.5,
                        name = function() return l10n("Disable Phase reminder"); end,
                        desc = function() return l10n("Enable or disable the reminder on login to set the Isle of Quel'Danas phase"); end,
                        disabled = function() return Expansions.Current <= Expansions.Tbc end,
                        width = 1,
                        get = function() return Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled; end,
                        set = function(_, value)
                            Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled = value
                        end,
                    },
                },
            },

            Spacer_A = QuestieOptionsUtils:Spacer(2.9),
            locale_header = {
                type = "header",
                order = 3,
                name = function() return l10n("Localization Settings"); end,
            },
            locale_dropdown = {
                type = "select",
                order = 3.1,
                values = _GetLanguages,
                style = "dropdown",
                name = function() return l10n("Select UI Locale"); end,
                get = function()
                    if not Questie.db.global.questieLocaleDiff then
                        return "auto"
                    else
                        return l10n:GetUILocale();
                    end
                end,
                set = function(_, lang)
                    if lang == "auto" then
                        local clientLocale = GetLocale()
                        if QUESTIE_LOCALES_OVERRIDE ~= nil then
                            clientLocale = QUESTIE_LOCALES_OVERRIDE.locale
                        end
                        l10n:SetUILocale(clientLocale)
                        Questie.db.global.questieLocale = clientLocale
                        Questie.db.global.questieLocaleDiff = false
                    else
                        l10n:SetUILocale(lang);
                        Questie.db.global.questieLocale = lang;
                        Questie.db.global.questieLocaleDiff = true;
                    end
                end,
            },
            Spacer_C = QuestieOptionsUtils:Spacer(3.9),
            reset_header = {
                type = "header",
                order = 4,
                name = function() return l10n("Reset Questie"); end,
            },
            Spacer_D = QuestieOptionsUtils:Spacer(22),
            reset_text = {
                type = "description",
                order = 4.1,
                name = function() return l10n("Hitting this button will reset all of the Questie configuration settings back to their default values. (Excluding Localization)"); end,
                fontSize = "medium",
            },
            questieReset = {
                type = "execute",
                order = 4.2,
                name = function() return l10n("Reset Questie"); end,
                desc = function() return l10n("Reset Questie to the default values for all settings."); end,
                func = function (_, _)
                    -- update all values to default
                    for k,v in pairs(optionsDefaults.profile) do
                       Questie.db.profile[k] = v
                    end

                    -- only toggle questie if it"s off (must be called before resetting the value)
                    if (not Questie.db.profile.enabled) then
                        Questie.db.profile.enabled = true
                        --QuestieQuest:ToggleNotes(true);
                    end

                    Questie.db.profile.enabled = optionsDefaults.profile.enabled;
                    Questie.db.profile.lowLevelStyle = optionsDefaults.profile.lowLevelStyle;

                    Questie.db.profile.migrationVersion = nil

                    Questie.db.profile.minimap.hide = optionsDefaults.profile.minimap.hide;

                    if Questie.IsSoD then
                        Questie.db.global.sod.dbIsCompiled = false
                    else
                        Questie.db.global.dbIsCompiled = false
                    end

                    Questie.db.char.hidden = nil
                    Questie.db.char.hiddenDailies = optionsDefaults.char.hiddenDailies;

                    ReloadUI()

                end,
            },
            Spacer_E = QuestieOptionsUtils:Spacer(4.3),
            questieJourneyReset = {
                type = "execute",
                order = 4.4,
                name = function() return l10n("Reset Questie Journey"); end,
                desc = function() return l10n("Clear the Journey of the current character"); end,
                func = function(_,_)
                    Questie.db.char.journey = nil

                    ReloadUI()
                end,
            },
            Spacer_F = QuestieOptionsUtils:Spacer(4.5),
            recompileDatabase = {
                type = "execute",
                order = 4.6,
                name = function() return l10n("Recompile Database"); end,
                desc = function() return l10n("Forces a recompile of the Questie database. This will also reload the UI."); end,
                func = function (_, _)
                    if Questie.IsSoD then
                        Questie.db.global.sod.dbIsCompiled = false
                    else
                        Questie.db.global.dbIsCompiled = false
                    end
                    ReloadUI()
                end,
            },
            Spacer_G = QuestieOptionsUtils:Spacer(4.7),
            openProfiler = {
                type = "execute",
                order = 4.8,
                name = function() return l10n("Open Profiler"); end,
                desc = function() return l10n("Open the Questie profiler, this is useful for tracking down the source of lag / frame spikes."); end,
                func = function (_, _)
                    QuestieLoader:ImportModule("Profiler"):Start()
                end,
            },
            Spacer_H = QuestieOptionsUtils:Spacer(4.9),
            github_text = {
                type = "description",
                order = 4.10,
                name = function() return Questie:Colorize(l10n("Questie is under active development for World of Warcraft: Classic. Please check GitHub for the latest alpha builds or to report issues. Or join us on our discord! (( https://github.com/Questie/Questie/ ))"), "purple"); end,
                fontSize = "medium",
            },
            HeaderDev = {
                type = "header",
                order = 5,
                name = l10n("Developer Options"),
            },
            bugWorkarounds = {
                type = "toggle",
                order = 5.01,
                name = function() return l10n("Enable bug workarounds"); end,
                desc = function() return l10n("When enabled, Questie will hotfix vanilla UI bugs."); end,
                width = "full",
                get = function() return Questie.db.profile.bugWorkarounds; end,
                set = function (_, value)
                    Questie.db.profile.bugWorkarounds = value
                end
            },
            enableBugHintsForAllFlavors = {
                type = "toggle",
                order = 5.015,
                name = function() return l10n("Enable bug hints for all game versions") end,
                desc = function() return l10n("Enables the bug hint windows for all game versions, usually used for bug reports in SoD.") end,
                hidden = function() return Questie.IsSoD end,
                width = "full",
                get = function () return Questie.db.profile.enableBugHintsForAllFlavors; end,
                set = function (_, value)
                    Questie.db.profile.enableBugHintsForAllFlavors = value
                end,
            },
            showItemIDs = {
                type = "toggle",
                order = 5.02,
                name = function() return l10n("Show Item IDs"); end,
                desc = function() return l10n("When this is checked, the ID of items will shown in tooltips."); end,
                disabled = function() return (not Questie.db.profile.enableTooltips); end,
                width = "full",
                get = function() return Questie.db.profile.enableTooltipsItemID; end,
                set = function (_, value)
                    Questie.db.profile.enableTooltipsItemID = value
                end
            },
            showNPCIDs = {
                type = "toggle",
                order = 5.03,
                name = function() return l10n("Show NPC IDs"); end,
                desc = function() return l10n("When this is checked, the ID of NPCs will be shown in tooltips."); end,
                disabled = function() return (not Questie.db.profile.enableTooltips); end,
                width = "full",
                get = function() return Questie.db.profile.enableTooltipsNPCID; end,
                set = function (_, value)
                    Questie.db.profile.enableTooltipsNPCID = value
                end
            },
            showObjectIDs = {
                type = "toggle",
                order = 5.04,
                name = function() return l10n("Show Object IDs"); end,
                desc = function() return l10n("When this is checked, the ID of objects will be shown in tooltips. These are guesses and only show the first matching ID in the QuestieDB."); end,
                disabled = function() return (not Questie.db.profile.enableTooltips); end,
                width = "full",
                get = function() return Questie.db.profile.enableTooltipsObjectID; end,
                set = function (_, value)
                    Questie.db.profile.enableTooltipsObjectID = value
                end
            },
            showQuestIDs = {
                type = "toggle",
                order = 5.05,
                name = function() return l10n("Show Quest IDs"); end,
                desc = function() return l10n("When this is checked, the ID of quests will show in tooltips and the tracker."); end,
                disabled = function() return (not Questie.db.profile.enableTooltips); end,
                width = "full",
                get = function() return Questie.db.profile.enableTooltipsQuestID; end,
                set = function (_, value)
                    Questie.db.profile.enableTooltipsQuestID = value
                    QuestieTracker:Update()
                end
            },
            debugEnabled = {
                type = "toggle",
                order = 5.06,
                name = function() return l10n("Enable Debug"); end,
                desc = function() return l10n("Enable or disable debug functionality."); end,
                width = "full",
                get = function () return Questie.db.profile.debugEnabled; end,
                set = function (_, value)
                    Questie.db.profile.debugEnabled = value
                    if Questie.db.profile.debugEnabled then
                        QuestieLoader:PopulateGlobals()
                    end
                end,
            },
            skipValidation = {
                type = "toggle",
                order = 5.07,
                name = function() return l10n("Skip Validation"); end,
                desc = function() return l10n("Skip database validation upon recompile. Validation is only present with debug enabled in the first place."); end,
                width = "full",
                disabled = function() return not Questie.db.profile.debugEnabled; end,
                get = function () return Questie.db.profile.skipValidation; end,
                set = function (_, value)
                    Questie.db.profile.skipValidation = value
                end,
            },
            debugEnabledPrint = {
                type = "toggle",
                order = 5.08,
                disabled = function() return not Questie.db.profile.debugEnabled; end,
                name = function() return l10n("Enable Debug").."-PRINT" end,
                desc = function() return l10n("Enable or disable debug functionality.").."-PRINT" end,
                width = "full",
                get = function () return Questie.db.profile.debugEnabledPrint; end,
                set = function (_, value)
                    Questie.db.profile.debugEnabledPrint = value
                end,
            },
            debugLevel = {
                type = "multiselect",
                values = {
                    [0] = "DEBUG_CRITICAL",
                    [1] = "DEBUG_ELEVATED",
                    [2] = "DEBUG_INFO",
                    [3] = "DEBUG_DEVELOP",
                    [4] = "DEBUG_SPAM",
                },
                order = 5.09,
                name = function() return l10n("Debug level to print"); end,
                width = "normal",
                disabled = function() return not (Questie.db.profile.debugEnabledPrint and Questie.db.profile.debugEnabled); end,
                get = function(_, key)
                    --Questie:Debug(Questie.DEBUG_SPAM, "Debug Key:", key, math.pow(2, key), state.option.values[key])
                    --Questie:Debug(Questie.DEBUG_SPAM, "Debug Level:", Questie.db.profile.debugLevel, bit.band(Questie.db.profile.debugLevel, math.pow(2, key)))
                    return bit.band(Questie.db.profile.debugLevel, math.pow(2, key)) > 0
                end,
                set = function (_, value)
                    local currentValue = Questie.db.profile.debugLevel
                    local flag = math.pow(2, value)
                    --Questie:Debug(Questie.DEBUG_SPAM, "Setting Debug:", currentValue, flag, bit.band(currentValue, flag)>0)
                    -- When current debug level is active, remove it
                    if (bit.band(currentValue, flag) > 0) then
                        Questie.db.profile.debugLevel = bit.bxor(flag, currentValue)
                    -- When current debug level is inactive, add it
                    else
                        Questie.db.profile.debugLevel = bit.bor(flag, currentValue)
                    end
                end,
            },
        },
    }
end

_GetLanguages = function()
    local languages = {
        ["auto"] = l10n("Automatic"),
        ["enUS"] = "English",
        ["deDE"] = "Deutsch",
        ["esES"] = "Español",
        ["esMX"] = "Español (América Latina)",
        ["frFR"] = "Français",
        ["koKR"] = "한국어",
        ["ptBR"] = "Português",
        ["ruRU"] = "Русский",
        ["zhCN"] = "简体中文",
        ["zhTW"] = "繁體中文",
    }
    if QUESTIE_LOCALES_OVERRIDE ~= nil then
        languages[QUESTIE_LOCALES_OVERRIDE.locale] = QUESTIE_LOCALES_OVERRIDE.localeName
    end
    return languages
end
