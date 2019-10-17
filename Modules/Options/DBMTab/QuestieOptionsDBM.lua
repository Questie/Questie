QuestieOptions.tabs.dbm = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


--TODO, hid hud tab if DBMHudMap global doesn't exist? Or at very least gray out options?
--dbmHUDEnable, dbmHUDShowAlert, DBMHUDZoom, dbmHUDRadius, dbmHUDShowQuest, dbmHUDShowSlay, dbmHUDShowLoot, dbmHUDShowInteract
function QuestieOptions.tabs.dbm:Initalize()
    return {
        name = function() return QuestieLocale:GetUIString('DBM_HUD_TAB'); end,
        type = "group",
        disabled = function() if DBMHudMap then return false else return true end end,
        order = 13.2,
        args = {
            hud_options = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_TAB'); end,
            },
            dbmHUDEnable = {
                type = "toggle",
                order = 3,
                name = function() return QuestieLocale:GetUIString('ENABLE_DBM_HUD'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_DBM_HUD_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)

                    if value then
                        QuestieDBMIntegration:EnableHUD()
                        --Hud Integration is completely innert when disabled, so QuestieDBMIntegration:SoftReset() cannot be used since it has no local tables
                        --Questies SmoothReset must be used after enabling hud so that HUD can build it's own tables when initial icons get added
                        QuestieQuest:SmoothReset()
                    else
                        QuestieDBMIntegration:ClearAll(true)--Passing true unregisters events and completely disables HUD activity after the ClearAll
                    end
                end,
            },
            dbmHUDShowAlert = {
                type = "toggle",
                order = 3.1,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_ICON_ALERT'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_ICON_ALERT_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:SoftReset()
                end,
            },
            DBMHUDRefresh = {
                type = "range",
                disabled = function() if DBMHudMap and not DBMHudMap.Version then return true else return false end end,
                order = 4,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_REFRESH'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_REFRESH_DESC', optionsDefaults.global.DBMHUDRefresh); end,
                width = "double",
                min = 0.01,
                max = 0.05,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:ChangeRefreshRate(value)
                end,
            },
            Spacer_A = QuestieOptionsUtils:Spacer(6),
            mapnote_options = {
                type = "header",
                order = 7,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_SCALE_OPTIONS'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(8),
            DBMHUDZoom = {
                type = "range",
                order = 9,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_ZOOM'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_ZOOM_DESC', optionsDefaults.global.DBMHUDZoom); end,
                width = "double",
                min = 40,
                max = 200,
                step = 20,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:ChangeZoomLevel(value)
                end,
            },
            dbmHUDRadius = {
                type = "range",
                order = 9,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_RADIUS'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_RADIUS_DESC', optionsDefaults.global.dbmHUDRadius); end,
                width = "double",
                min = 1,
                max = 5,
                step = 0.5,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:SoftReset()
                end,
            },
            Spacer_C = QuestieOptionsUtils:Spacer(20),
            fade_options = {
                type = "header",
                order = 21,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_OPTIONS'); end,
            },
            Spacer_D = QuestieOptionsUtils:Spacer(22),
            dbmHUDShowQuest = {
                type = "toggle",
                order = 23,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_QUEST'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_QUEST_DESC', optionsDefaults.global.dbmHUDShowQuest); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:SoftReset()
                end,
            },
            dbmHUDShowSlay = {
                type = "toggle",
                order = 23,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_KILL'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_KILL_DESC', optionsDefaults.global.dbmHUDShowSlay); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:SoftReset()
                end,
            },
            dbmHUDShowLoot = {
                type = "toggle",
                order = 23,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_LOOT'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_LOOT_DESC', optionsDefaults.global.dbmHUDShowLoot); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:SoftReset()
                end,
            },
            dbmHUDShowInteract = {
                type = "toggle",
                order = 23,
                name = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_INTERACT'); end,
                desc = function() return QuestieLocale:GetUIString('DBM_HUD_FILTER_INTERACT_DESC', optionsDefaults.global.dbmHUDShowInteract); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieDBMIntegration:SoftReset()
                end,
            },
        },
    }
end