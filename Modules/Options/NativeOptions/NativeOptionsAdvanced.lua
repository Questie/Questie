---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")

-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieProfiler
local QuestieProfiler = QuestieLoader:ImportModule("Profiler")
---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")

QuestieOptionsEngine.tabs.advanced = { ... }
local optionsDefaults = QuestieOptionsDefaults:Load()

---@type fun(): table<string, string>
local _GetLanguages
---@type string|nil
local pendingLocaleSelection

---@return string locale
local function _GetAutomaticLocale()
    if QUESTIE_LOCALES_OVERRIDE ~= nil then
        return l10n:GetFallbackLocale(QUESTIE_LOCALES_OVERRIDE.locale)
    end
    return l10n:GetFallbackLocale(GetLocale())
end

function QuestieOptionsEngine.tabs.advanced:Initialize()
    return {
        title = "Advanced",
        subtitle = "Advanced Options",
        order = 6,
        icon = 134063,
        items = {
            hideStartupWarnings = {
                type = "checkbox",
                order = 1.05,
                title = "Hide Startup Warnings",
                tooltip = "Disables the \"Welcome to Cataclysm Classic\" message on startup.",
                visible = false,
                width = "full",
                get = function()
                    return Questie.db.profile.hideStartupWarnings
                end,
                set = function(self, value)
                    Questie.db.profile.hideStartupWarnings = value
                end,
            },
            enableIconLimit = {
                type = "checkbox",
                order = 1.1,
                title = "Enable Icon Limit",
                tooltip = "Enable the limit of icons drawn per type.",
                width = "full",
                get = function()
                    return Questie.db.profile.enableIconLimit
                end,
                set = function(self, value)
                    Questie.db.profile.enableIconLimit = value
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            iconLimit = {
                type = "slider",
                order = 1.2,
                title = "Icon Limit",
                tooltip = { "Limits the amount of icons drawn per type. (Default: %s)", optionsDefaults.profile.iconLimit },
                width = "half",
                min = 1,
                max = 5000,
                step = 10,
                enabled = function()
                    return Questie.db.profile.enableIconLimit
                end,
                get = function()
                    return Questie.db.profile.iconLimit
                end,
                set = function(self, value)
                    Questie.db.profile.iconLimit = value
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            objectiveFilterDistance = {
                type = "slider",
                order = 1.4,
                title = "Objective icon filter distance",
                tooltip = "Minimum distance between two objective icons in the same zone.\n\nSet to 0 to show all icons. Higher values reduce icon clutter.",
                width = "half",
                min = 0,
                max = 5,
                step = 1,
                enabled = function()
                    return Questie.db.profile.enabled
                end,
                get = function()
                    return Questie.db.profile.objectiveFilterDistance
                end,
                set = function(self, value)
                    Questie.db.profile.objectiveFilterDistance = value
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting objective filter distance to %s : Redrawing!", value))
                end,
            },
            spawnFilterDistance = {
                type = "slider",
                order = 1.41,
                title = "Available quest filter distance",
                tooltip = "How far away a spawn starting a quest needs to be inside a zone before another spawn of the same creature or object is added.\n\nWARNING! Setting this to lower values may result in a lot of icons being drawn and can impact map performance!",
                width = "half",
                min = 1,
                max = 100,
                step = 1,
                enabled = function()
                    return Questie.db.profile.enabled
                end,
                get = function()
                    return Questie.db.profile.spawnFilterDistance
                end,
                set = function(self, value)
                    Questie.db.profile.spawnFilterDistance = value
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            availableIconLimit = {
                type = "slider",
                order = 1.43,
                title = "Available quest icon limit",
                tooltip = "This setting limits the number of icons starting a single quest.\n\nSetting to zero means there is no limit (except through other settings).\n\nWARNING! Setting this to 0 may result in a lot of icons being drawn and can impact map performance!",
                width = "half",
                min = 0,
                max = 500,
                step = 1,
                enabled = function()
                    return Questie.db.profile.enabled
                end,
                get = function()
                    return Questie.db.profile.availableIconLimit
                end,
                set = function(self, value)
                    Questie.db.profile.availableIconLimit = value
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, l10n("Setting icon limit value to %s : Redrawing!", value))
                end,
            },
            npcrules_group = {
                type = "container",
                order = 1.5,
                title = "Quel'Danas Settings",
                visible = Questie.IsTBC,
                items = {
                    isleOfQuelDanasPhase = {
                        type = "dropdown",
                        order = 1.1,
                        title = "Isle of Quel'Danas Phase",
                        tooltip = "Select the phase fitting your realm progress on the Isle of Quel'Danas",
                        width = "half",
                        options = IsleOfQuelDanas.localizedPhaseNames,
                        enabled = function()
                            return Expansions.Current > Expansions.Tbc
                        end,
                        get = function()
                            return Questie.db.profile.isleOfQuelDanasPhase
                        end,
                        set = function(key)
                            Questie.db.profile.isleOfQuelDanasPhase = key
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    isleOfQuelDanasPhaseReminder = {
                        type = "checkbox",
                        order = 1.2,
                        title = "Disable Phase reminder",
                        tooltip = "Enable or disable the reminder on login to set the Isle of Quel'Danas phase",
                        width = "half",
                        enabled = function()
                            return Expansions.Current > Expansions.Tbc
                        end,
                        get = function()
                            return Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled
                        end,
                        set = function(self, value)
                            Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled = value
                        end,
                    },
                },
            },
            locale_header = {
                type = "divider",
                order = 3,
                title = "Localization Settings",
                width = "full",
            },
            locale_dropdown = {
                type = "dropdown",
                order = 3.1,
                title = "Select UI Locale",
                width = "half",
                options = _GetLanguages,
                get = function()
                    if not Questie.db.global.questieLocaleDiff then
                        return "auto"
                    end
                    return l10n:GetUILocale()
                end,
                set = function(lang)
                    local currentSelectedLocale = Questie.db.global.questieLocaleDiff and l10n:GetUILocale() or "auto"
                    if lang == currentSelectedLocale then
                        return
                    end

                    local currentEffectiveLocale = currentSelectedLocale == "auto" and _GetAutomaticLocale()
                        or l10n:GetFallbackLocale(currentSelectedLocale)
                    local newEffectiveLocale = lang == "auto" and _GetAutomaticLocale()
                        or l10n:GetFallbackLocale(lang)

                    if currentEffectiveLocale == newEffectiveLocale then
                        l10n:SetUILocale(newEffectiveLocale)
                        Questie.db.global.questieLocale = newEffectiveLocale
                        Questie.db.global.questieLocaleDiff = (lang ~= "auto")
                        return
                    end

                    pendingLocaleSelection = lang
                    Popup.Show("QUESTIE_LOCALE_CHANGE_CONFIRM_NATIVE")
                end,
            },
            reset_header = {
                type = "divider",
                order = 4,
                title = "Reset Questie",
                width = "full",
            },
            reset_text = {
                type = "text",
                order = 4.1,
                title = "Hitting this button will reset all of the Questie configuration settings back to their default values. (Excluding Localization)",
                width = "full",
                titleSize = 12,
            },
            github_text = {
                type = "text",
                order = 4.15,
                title = "Questie is under active development for World of Warcraft: Classic. Please check GitHub for the latest alpha builds or to report issues. Or join us on our discord! (( https://github.com/Questie/Questie/ ))",
                titleFormat = function(var) return Questie:Colorize(var, "purple") end,
                width = "full",
                titleSize = 12,
            },
            questieReset = {
                type = "button",
                order = 4.2,
                title = "Reset Questie",
                btnLabel = "Reset Questie",
                tooltip = "Reset Questie to the default values for all settings.",
                width = "half",
                align = "CENTER",
                func = function()
                    Popup.Show("QUESTIE_RESET_CONFIRM_NATIVE")
                end,
            },
            questieJourneyReset = {
                type = "button",
                order = 4.3,
                title = "Reset Questie Journey",
                btnLabel = "Reset Questie Journey",
                tooltip = "Clear the Journey of the current character",
                width = "half",
                align = "CENTER",
                func = function()
                    Popup.Show("QUESTIE_JOURNEY_RESET_CONFIRM_NATIVE")
                end,
            },
            openProfiler = {
                type = "button",
                order = 4.4,
                title = "Open Profiler",
                btnLabel = "Open Profiler",
                tooltip = "Open the Questie profiler, this is useful for tracking down the source of lag / frame spikes.",
                width = "half",
                align = "CENTER",
                func = function()
                    QuestieProfiler:OpenUI()
                end,
            },
            journeyBrowseCharacters = {
                type = "button",
                order = 4.5,
                title = "Import Journey data",
                btnLabel = "Import Journey data",
                tooltip = "Browse other characters on this account and import their journey data.",
                width = "half",
                align = "CENTER",
                func = function()
                    QuestieJourney:ShowCharacterBrowserFrame()
                end,
            },
            HeaderDev = {
                type = "divider",
                order = 5,
                title = "Developer Options",
                width = "full",
            },
            bugWorkarounds = {
                type = "checkbox",
                order = 5.01,
                title = "Enable bug workarounds",
                tooltip = "If checked, Questie will hotfix vanilla UI bugs.",
                width = "half",
                get = function()
                    return Questie.db.profile.bugWorkarounds
                end,
                set = function(self, value)
                    Questie.db.profile.bugWorkarounds = value
                end,
            },
            enableBugHintsForAllFlavors = {
                type = "checkbox",
                order = 5.015,
                title = "Enable bug hints for all game versions",
                tooltip = "Enables the bug hint windows for all game versions, usually used for bug reports in SoD.",
                visible = not Questie.IsSoD,
                width = "half",
                get = function()
                    return Questie.db.profile.enableBugHintsForAllFlavors
                end,
                set = function(self, value)
                    Questie.db.profile.enableBugHintsForAllFlavors = value
                end,
            },
            showItemIDs = {
                type = "checkbox",
                order = 5.02,
                title = "Show Item IDs",
                tooltip = "If checked, the ID of items will shown in tooltips.",
                width = "half",
                enabled = function()
                    return Questie.db.profile.enableTooltips
                end,
                get = function()
                    return Questie.db.profile.enableTooltipsItemID
                end,
                set = function(self, value)
                    Questie.db.profile.enableTooltipsItemID = value
                end,
            },
            showNPCIDs = {
                type = "checkbox",
                order = 5.03,
                title = "Show NPC IDs",
                tooltip = "If checked, the ID of NPCs will be shown in tooltips.",
                width = "half",
                enabled = function()
                    return Questie.db.profile.enableTooltips
                end,
                get = function()
                    return Questie.db.profile.enableTooltipsNPCID
                end,
                set = function(self, value)
                    Questie.db.profile.enableTooltipsNPCID = value
                end,
            },
            showObjectIDs = {
                type = "checkbox",
                order = 5.04,
                title = "Show Object IDs",
                tooltip = "If checked, the ID of objects will be shown in tooltips. These are guesses and only show the first matching ID in the QuestieDB.",
                width = "half",
                enabled = function()
                    return Questie.db.profile.enableTooltips
                end,
                get = function()
                    return Questie.db.profile.enableTooltipsObjectID
                end,
                set = function(self, value)
                    Questie.db.profile.enableTooltipsObjectID = value
                    if value then
                        LibQuestieDB.Object.BuildNameIndex()
                    end
                end,
            },
            showSpellIDs = {
                type = "checkbox",
                order = 5.045,
                title = "Show Spell IDs",
                tooltip = "If checked, the ID of spells will be shown in tooltips.",
                width = "half",
                enabled = function()
                    return Questie.db.profile.enableTooltips
                end,
                get = function()
                    return Questie.db.profile.enableTooltipsSpellID
                end,
                set = function(self, value)
                    Questie.db.profile.enableTooltipsSpellID = value
                end,
            },
            showQuestIDs = {
                type = "checkbox",
                order = 5.05,
                title = "Show Quest IDs",
                tooltip = "If checked, the ID of quests will show in tooltips and the tracker.",
                width = "half",
                enabled = function()
                    return Questie.db.profile.enableTooltips
                end,
                get = function()
                    return Questie.db.profile.enableTooltipsQuestID
                end,
                set = function(self, value)
                    Questie.db.profile.enableTooltipsQuestID = value
                    QuestieTracker:Update()
                end,
            },
            waypointDebugHover = {
                type = "checkbox",
                order = 5.055,
                title = "Show waypoint hover area",
                tooltip = "Draws the area around each patrol path on the world map where hovering shows its NPC.",
                width = "half",
                get = function()
                    return Questie.db.profile.waypointDebugHover
                end,
                set = function(self, value)
                    Questie.db.profile.waypointDebugHover = value
                    QuestieWaypoints.Refresh()
                end,
            },
            debugEnabled = {
                type = "checkbox",
                order = 5.06,
                title = "Enable Debug",
                tooltip = "Enable or disable debug functionality.",
                width = "half",
                get = function()
                    return Questie.db.profile.debugEnabled
                end,
                set = function(self, value)
                    Questie.db.profile.debugEnabled = value
                    if Questie.db.profile.debugEnabled then
                        QuestieLoader:PopulateGlobals()
                    end
                end,
            },
            debugEnabledPrint = {
                type = "checkbox",
                order = 5.07,
                title = "Enable Debug-PRINT",
                tooltip = "Enable or disable debug functionality.-PRINT",
                width = "half",
                enabled = function()
                    return Questie.db.profile.debugEnabled
                end,
                get = function()
                    return Questie.db.profile.debugEnabledPrint
                end,
                set = function(self, value)
                    Questie.db.profile.debugEnabledPrint = value
                end,
            },
            debugLevelContainer = {
                type = "container",
                order = 5.08,
                title = "Debug level to print",
                enabled = function()
                    return Questie.db.profile.debugEnabled and Questie.db.profile.debugEnabledPrint
                end,
                items = {
                    debugCritical = {
                        order = 1,
                        type = "checkbox",
                        title = "DEBUG_CRITICAL",
                        width = "third",
                        enabled = function()
                            return Questie.db.profile.debugEnabled and Questie.db.profile.debugEnabledPrint
                        end,
                        get = function()
                            return bit.band(Questie.db.profile.debugLevel or 0, 1) > 0
                        end,
                        set = function(self, val)
                            local current = Questie.db.profile.debugLevel or 0
                            if val then
                                Questie.db.profile.debugLevel = bit.bor(current, 1)
                            else
                                Questie.db.profile.debugLevel = bit.band(current, bit.bnot(1))
                            end
                        end,
                    },
                    debugElevated = {
                        order = 2,
                        type = "checkbox",
                        title = "DEBUG_ELEVATED",
                        width = "third",
                        enabled = function()
                            return Questie.db.profile.debugEnabled and Questie.db.profile.debugEnabledPrint
                        end,
                        get = function()
                            return bit.band(Questie.db.profile.debugLevel or 0, 2) > 0
                        end,
                        set = function(self, val)
                            local current = Questie.db.profile.debugLevel or 0
                            if val then
                                Questie.db.profile.debugLevel = bit.bor(current, 2)
                            else
                                Questie.db.profile.debugLevel = bit.band(current, bit.bnot(2))
                            end
                        end,
                    },
                    debugInfo = {
                        order = 3,
                        type = "checkbox",
                        title = "DEBUG_INFO",
                        width = "third",
                        enabled = function()
                            return Questie.db.profile.debugEnabled and Questie.db.profile.debugEnabledPrint
                        end,
                        get = function()
                            return bit.band(Questie.db.profile.debugLevel or 0, 4) > 0
                        end,
                        set = function(self, val)
                            local current = Questie.db.profile.debugLevel or 0
                            if val then
                                Questie.db.profile.debugLevel = bit.bor(current, 4)
                            else
                                Questie.db.profile.debugLevel = bit.band(current, bit.bnot(4))
                            end
                        end,
                    },
                    debugDevelop = {
                        order = 4,
                        type = "checkbox",
                        title = "DEBUG_DEVELOP",
                        width = "third",
                        enabled = function()
                            return Questie.db.profile.debugEnabled and Questie.db.profile.debugEnabledPrint
                        end,
                        get = function()
                            return bit.band(Questie.db.profile.debugLevel or 0, 8) > 0
                        end,
                        set = function(self, val)
                            local current = Questie.db.profile.debugLevel or 0
                            if val then
                                Questie.db.profile.debugLevel = bit.bor(current, 8)
                            else
                                Questie.db.profile.debugLevel = bit.band(current, bit.bnot(8))
                            end
                        end,
                    },
                    debugSpam = {
                        order = 5,
                        type = "checkbox",
                        title = "DEBUG_SPAM",
                        width = "third",
                        enabled = function()
                            return Questie.db.profile.debugEnabled and Questie.db.profile.debugEnabledPrint
                        end,
                        get = function()
                            return bit.band(Questie.db.profile.debugLevel or 0, 16) > 0
                        end,
                        set = function(self, val)
                            local current = Questie.db.profile.debugLevel or 0
                            if val then
                                Questie.db.profile.debugLevel = bit.bor(current, 16)
                            else
                                Questie.db.profile.debugLevel = bit.band(current, bit.bnot(16))
                            end
                        end,
                    },
                },
            },
        },
    }
end

Popup.Dialogs["QUESTIE_RESET_CONFIRM_NATIVE"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        for k, v in pairs(optionsDefaults.profile) do
            Questie.db.profile[k] = v
        end

        if not Questie.db.profile.enabled then
            Questie.db.profile.enabled = true
        end

        Questie.db.profile.enabled = optionsDefaults.profile.enabled
        Questie.db.profile.lowLevelStyle = optionsDefaults.profile.lowLevelStyle
        Questie.db.profile.migrationVersion = nil
        Questie.db.profile.minimap.hide = optionsDefaults.profile.minimap.hide

        Questie.db.char.hidden = nil
        Questie.db.char.hiddenDailies = optionsDefaults.char.hiddenDailies
        Questie.db.global.unavailableQuestsDeterminedByTalking = {}
        Questie.db.global.unavailableDailyQuestsByNpc = {}

        ReloadUI()
    end,
    OnShow = function(self)
        local confirmText = l10n("Are you sure you want to reset Questie to default settings?")
        self.Text:SetText(confirmText)
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

Popup.Dialogs["QUESTIE_JOURNEY_RESET_CONFIRM_NATIVE"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        Questie.db.char.journey = nil
        ReloadUI()
    end,
    OnShow = function(self)
        local confirmText = l10n("Are you sure you want to reset the Questie Journey for this character?")
        self.Text:SetText(confirmText)
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

Popup.Dialogs["QUESTIE_LOCALE_CHANGE_CONFIRM_NATIVE"] = {
    noCancelOnReuse = true,
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        if not pendingLocaleSelection then
            return
        end

        local effectiveLocale = pendingLocaleSelection == "auto" and _GetAutomaticLocale()
            or l10n:GetFallbackLocale(pendingLocaleSelection)

        l10n:SetUILocale(effectiveLocale)
        Questie.db.global.questieLocale = effectiveLocale
        Questie.db.global.questieLocaleDiff = (pendingLocaleSelection ~= "auto")
        pendingLocaleSelection = nil
        ReloadUI()
    end,
    OnCancel = function(self)
        pendingLocaleSelection = nil
    end,
    OnShow = function(self)
        local confirmText = l10n("This will reload the UI. Are you sure you want to change the language?")
        self.Text:SetText(confirmText)
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

_GetLanguages = function()
    local languages = {
        ["auto"] = l10n("Automatic") .. " (" .. _GetAutomaticLocale() .. ")",
        ["enUS"] = "English",
        ["deDE"] = "Deutsch",
        ["esES"] = "Español (España)",
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