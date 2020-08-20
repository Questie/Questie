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

QuestieOptions.tabs.minimap = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.minimap:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('MINIMAP_TAB'); end,
        type = "group",
        order = 11,
        args = {
            minimap_options = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('MINIMAP_OPTIONS_HEADER'); end,
            },
            alwaysGlowMinimap = {
                type = "toggle",
                order = 1.1,
                name = function() return QuestieLocale:GetUIString('MINIMAP_ALWAYS_GLOW_TOGGLE'); end,
                desc = function() return QuestieLocale:GetUIString('MINIMAP_ALWAYS_GLOW_TOGGLE_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieFramePool:UpdateGlowConfig(true, value)
                end,
            },
            questMinimapObjectiveColors = {
                type = "toggle",
                order = 1.2,
                name = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS'); end,
                desc = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieFramePool:UpdateColorConfig(true, value)
                end,
            },
            Spacer_A = QuestieOptionsUtils:Spacer(1.9),
            mapnote_options = {
                type = "header",
                order = 2,
                name = function() return QuestieLocale:GetUIString('MINIMAP_NOTES_HEADER'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(2.1),
            globalMiniMapScale = {
                type = "range",
                order = 2.2,
                name = function() return QuestieLocale:GetUIString('MINIMAP_GLOBAL_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('MINIMAP_GLOBAL_SCALE_DESC', optionsDefaults.global.globalMiniMapScale); end,
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
            fadeLevel = {
                type = "range",
                order = 2.3,
                name = function() return QuestieLocale:GetUIString('MINIMAP_FADING'); end,
                desc = function() return QuestieLocale:GetUIString('MINIMAP_FADING_DESC', optionsDefaults.global.fadeLevel); end,
                width = "double",
                min = 10,
                max = 100,
                step = 1,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            Spacer_D = QuestieOptionsUtils:Spacer(2.31),
            fadeOverPlayer = {
                type = "toggle",
                order = 2.4,
                name = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER'); end,
                desc = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            fadeOverPlayerDistance = {
                type = "range",
                order = 2.5,
                name = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_DIST'); end,
                desc = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_DIST_DESC', optionsDefaults.global.fadeOverPlayerDistance); end,
                width = "double",
                min = 0,
                max = 20,
                step = 0.5,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                disabled = function() return (not Questie.db.global.fadeOverPlayer); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            fadeOverPlayerLevel = {
                type = "range",
                order = 2.6,
                name = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_LEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_LEVEL_DESC', optionsDefaults.global.fadeOverPlayerLevel); end,
                width = "double",
                min = 0.1,
                max = 1,
                step = 0.1,
                disabled = function() return (not Questie.db.global.fadeOverPlayer); end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            Spacer_E = QuestieOptionsUtils:Spacer(2.9),
            fade_options = {
                type = "header",
                order = 3,
                name = function() return QuestieLocale:GetUIString('MINMAP_COORDS_HEADER'); end,
            },
            Spacer_F = QuestieOptionsUtils:Spacer(3.1),
            minimapCoordinatesEnabled = {
                type = "toggle",
                order = 3.2,
                name = function() return QuestieLocale:GetUIString('ENABLE_COORDS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_COORDS_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)

                    if not value then
                        QuestieCoords:ResetMinimapText();
                    end
                end,
            },
        },
    }
end