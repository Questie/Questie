-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration")

QuestieOptionsEngine.tabs.dbm = { ... }
local optionsDefaults = QuestieOptionsDefaults:Load()

local function _IsDBMEnabled()
    return Questie.db.profile.dbmHUDEnable and ((DBM and DBM.HudMap) ~= nil)
end

function QuestieOptionsEngine.tabs.dbm:Initialize()
    return {
        title = "DBM HUD",
        subtitle = "Deadly Boss Mods HUD Integration",
        order = 5,
        icon = 134442,
        visible = ((DBM and DBM.HudMap) ~= nil),
        items = {
            info_text = {
                type = "text",
                order = 0.1,
                title = "",
                description = "The DBM HUD integrates with the addon DeadlyBossMods to show a radar of objective icons on your entire screen. Enabling this feature usually requires a /reload to take effect.",
                width = "full",
            },
            hud_options_group = {
                type = "container",
                order = 1,
                title = "DBM HUD Options",
                items = {
                    dbmHUDEnable = {
                        type = "checkbox",
                        order = 1.1,
                        title = "Show DBM HUD",
                        tooltip = "Enable or disable the DBM Heads Up Display (HUD) overlay for showing map objects.",
                        width = "full",
                        get = function() return Questie.db.profile.dbmHUDEnable end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDEnable = value
                            if value then
                                QuestieDBMIntegration:EnableHUD()
                                QuestieQuest:SmoothReset()
                            else
                                QuestieDBMIntegration:ClearAll(true)
                            end
                        end,
                    },
                    dbmHUDShowAlert = {
                        type = "checkbox",
                        order = 1.2,
                        title = "Enable proximity visual for HUD icons",
                        tooltip = "Changes the color of a HUD icon to red when you are near it.",
                        width = "full",
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.dbmHUDShowAlert end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDShowAlert = value
                            QuestieDBMIntegration:SoftReset()
                        end,
                    },
                    DBMHUDRefresh = {
                        type = "slider",
                        order = 1.3,
                        title = "Refresh rate for HUD (Requires turning HUD off/on)",
                        tooltip = {"Adjusts the fresh rate for HUD Icons which affects how often UI refreshes their position. (Default: %s)", optionsDefaults.profile.DBMHUDRefresh},
                        width = "full",
                        min = 0.01,
                        max = 0.05,
                        step = 0.01,
                        enabled = function()
                            return _IsDBMEnabled() and (DBM.HudMap.Version ~= nil)
                        end,
                        get = function() return Questie.db.profile.DBMHUDRefresh end,
                        set = function(_, value)
                            Questie.db.profile.DBMHUDRefresh = value
                            QuestieDBMIntegration:ChangeRefreshRate(value)
                        end,
                    },
                },
            },
            size_options_group = {
                type = "container",
                order = 2,
                title = "Size & Scale Options",
                enabled = _IsDBMEnabled,
                items = {
                    DBMHUDZoom = {
                        type = "slider",
                        order = 2.1,
                        title = "Global zoom level for HUD Icons",
                        tooltip = {"Adjusts the zoom level for HUD Icons which affects how close in or how far out you see them. (Default: %s)", optionsDefaults.profile.DBMHUDZoom},
                        width = "half",
                        min = 40,
                        max = 200,
                        step = 20,
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.DBMHUDZoom end,
                        set = function(_, value)
                            Questie.db.profile.DBMHUDZoom = value
                            QuestieDBMIntegration:ChangeZoomLevel(value)
                        end,
                    },
                    dbmHUDRadius = {
                        type = "slider",
                        order = 2.2,
                        title = "Global radius/size for HUD Icons",
                        tooltip = {"Adjusts the size of the icons that appear on the HUD. (Default: %s)", optionsDefaults.profile.dbmHUDRadius},
                        width = "half",
                        min = 1,
                        max = 5,
                        step = 0.5,
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.dbmHUDRadius end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDRadius = value
                            QuestieDBMIntegration:SoftReset()
                        end,
                    },
                },
            },
            filter_options_group = {
                type = "container",
                order = 3,
                title = "Filter Options",
                enabled = _IsDBMEnabled,
                items = {
                    dbmHUDShowQuest = {
                        type = "checkbox",
                        order = 3.1,
                        title = "Show quest giver icons",
                        tooltip = {"Toggles whether or not available/complete quest icons appear on the HUD.", optionsDefaults.profile.dbmHUDShowQuest},
                        width = "half",
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.dbmHUDShowQuest end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDShowQuest = value
                            QuestieDBMIntegration:SoftReset()
                        end,
                    },
                    dbmHUDShowSlay = {
                        type = "checkbox",
                        order = 3.2,
                        title = "Show slay icons",
                        tooltip = {"Toggles whether or not slay icons appear on the HUD.", optionsDefaults.profile.dbmHUDShowSlay},
                        width = "half",
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.dbmHUDShowSlay end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDShowSlay = value
                            QuestieDBMIntegration:SoftReset()
                        end,
                    },
                    dbmHUDShowLoot = {
                        type = "checkbox",
                        order = 3.3,
                        title = "Show loot icons",
                        tooltip = {"Toggles whether or not loot icons appear on the HUD.", optionsDefaults.profile.dbmHUDShowLoot},
                        width = "half",
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.dbmHUDShowLoot end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDShowLoot = value
                            QuestieDBMIntegration:SoftReset()
                        end,
                    },
                    dbmHUDShowInteract = {
                        type = "checkbox",
                        order = 3.4,
                        title = "Show object interact icons",
                        tooltip = {"Toggles whether or not object (gear) icons appear on the HUD.", optionsDefaults.profile.dbmHUDShowInteract},
                        width = "half",
                        enabled = _IsDBMEnabled,
                        get = function() return Questie.db.profile.dbmHUDShowInteract end,
                        set = function(_, value)
                            Questie.db.profile.dbmHUDShowInteract = value
                            QuestieDBMIntegration:SoftReset()
                        end,
                    },
                },
            },
        },
    }
end