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
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.minimap = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.minimap:Initialize()
    return {
        name = function() return l10n('Minimap'); end,
        type = "group",
        order = 11,
        args = {
            minimap_options = {
                type = "header",
                order = 1,
                name = function() return l10n('Minimap Options'); end,
            },
            alwaysGlowMinimap = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Always Glow Behind Minimap Icons'); end,
                desc = function() return l10n('Draw a glow texture behind minimap icons, colored unique to each quest.'); end,
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
                name = function() return l10n('Different Map Icon Color for Each Quest'); end,
                desc = function() return l10n('Show map icons with colors that are randomly generated based on quest ID.'); end,
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
                name = function() return l10n('Minimap Note Options'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(2.1),
            globalMiniMapScale = {
                type = "range",
                order = 2.2,
                name = function() return l10n('Global Scale for Minimap Icons'); end,
                desc = function() return l10n('How large the Minimap icons are. ( Default: %s )', optionsDefaults.global.globalMiniMapScale); end,
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
                name = function() return l10n('Fade objective distance'); end,
                desc = function() return l10n('How much objective icons should fade depending on distance. ( Default: %s )', optionsDefaults.global.fadeLevel); end,
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
                name = function() return l10n('Fade Icons over Player'); end,
                desc = function() return l10n('Fades icons on the minimap when your player walks near them.'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            fadeOverPlayerDistance = {
                type = "range",
                order = 2.5,
                name = function() return l10n('Fade over Player Distance'); end,
                desc = function() return l10n('How far from player should icons start to fade. ( Default: %s )', optionsDefaults.global.fadeOverPlayerDistance); end,
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
                name = function() return l10n('Fade over Player Amount'); end,
                desc = function() return l10n('How much should the icons around the player fade. ( Default: %s )', optionsDefaults.global.fadeOverPlayerLevel); end,
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
                name = function() return l10n('Minimap Coordinates'); end,
            },
            Spacer_F = QuestieOptionsUtils:Spacer(3.1),
            minimapCoordinatesEnabled = {
                type = "toggle",
                order = 3.2,
                name = function() return l10n('Player coordinates on the Minimap'); end,
                desc = function() return l10n("Place the Player's coordinates on the Minimap title."); end,
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