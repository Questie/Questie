-------------------------
--Import modules.
-------------------------
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

QuestieOptions.tabs.map = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.map:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('MAP_TAB'); end,
        type = "group",
        order = 12,
        args = {
            map_options = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('MAP_OPTIONS_HEADER'); end,
            },
            mapShowHideEnabled = {
                type = "toggle",
                order = 1.1,
                name = function() return QuestieLocale:GetUIString('ENABLE_MAP_BUTTON'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_BUTTON_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)

                    if value then
                        Questie_Toggle:Show();
                    else
                        Questie_Toggle:Hide();
                    end
                end,
            },
            alwaysGlowMap = {
                type = "toggle",
                order = 1.2,
                name = function() return QuestieLocale:GetUIString('MAP_ALWAYS_GLOW_TOGGLE'); end,
                desc = function() return QuestieLocale:GetUIString('MAP_ALWAYS_GLOW_TOGGLE_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieFramePool:UpdateGlowConfig(false, value)
                end,
            },
            questObjectiveColors = {
                type = "toggle",
                order = 1.3,
                name = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS'); end,
                desc = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieFramePool:UpdateColorConfig(false, value)
                end,
            },
            Spacer_A = QuestieOptionsUtils:Spacer(1.9),
            mapnote_options = {
                type = "header",
                order = 2,
                name = function() return QuestieLocale:GetUIString('MAP_NOTES'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(2.1),
            globalScale = {
                type = "range",
                order = 2.2,
                name = function() return QuestieLocale:GetUIString('MAP_GLOBAL_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('MAP_GLOBAL_SCALE_DESC', optionsDefaults.global.globalScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieMap:RescaleIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            availableScale = {
                type = "range",
                order = 2.3,
                name = function() return QuestieLocale:GetUIString('AVAILABLE_ICON_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('AVAILABLE_ICON_SCALE_DESC', optionsDefaults.global.availableScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieMap:RescaleIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            eventScale = {
                type = "range",
                order = 2.4,
                name = function() return QuestieLocale:GetUIString('EVENT_ICON_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('EVENT_ICON_SCALE_DESC', optionsDefaults.global.eventScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieMap:RescaleIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            lootScale = {
                type = "range",
                order = 2.5,
                name = function() return QuestieLocale:GetUIString('LOOT_ICON_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('LOOT_ICON_SCALE_DESC', optionsDefaults.global.lootScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieMap:RescaleIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            monsterScale = {
                type = "range",
                order = 2.6,
                name = function() return QuestieLocale:GetUIString('MONSTER_ICON_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('MONSTER_ICON_SCALE_DESC', optionsDefaults.global.monsterScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieMap:RescaleIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            objectScale = {
                type = "range",
                order = 2.7,
                name = function() return QuestieLocale:GetUIString('OBJECT_ICON_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('OBJECT_ICON_SCALE_DESC', optionsDefaults.global.objectScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieMap:RescaleIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            Spacer_C = QuestieOptionsUtils:Spacer(2.9),
            fade_options = {
                type = "header",
                order = 3,
                name = function() return QuestieLocale:GetUIString('MAP_COORDS'); end,
            },
            mapCoordinatesEnabled = {
                type = "toggle",
                order = 3.2,
                name = function() return QuestieLocale:GetUIString('ENABLE_MAP_COORDS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_COORDS_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)

                    if not value then
                        QuestieCoords.ResetMapText();
                    end
                end,
            },
            mapCoordinatePrecision = {
                type = "range",
                order = 3.3,
                name = function() return QuestieLocale:GetUIString('MAP_COORDS_PRECISION'); end,
                desc = function() return QuestieLocale:GetUIString('MAP_COORDS_PRECISION_DESC', optionsDefaults.global.mapCoordinatePrecision); end,
                width = "double",
                min = 1,
                max = 5,
                step = 1,
                disabled = function() return not Questie.db.global.mapCoordinatesEnabled end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            }
        },
    }
end
