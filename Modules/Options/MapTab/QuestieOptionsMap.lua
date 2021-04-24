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

QuestieOptions.tabs.map = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.map:Initialize()
    return {
        name = function() return l10n('Map'); end,
        type = "group",
        order = 12,
        args = {
            map_options = {
                type = "header",
                order = 1,
                name = function() return l10n('Map Options'); end,
            },
            mapShowHideEnabled = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Show Questie Map Button'); end,
                desc = function() return l10n('Enable or disable the Show/Hide Questie Button on Map (May fix some Map Addon interactions).'); end,
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
                name = function() return l10n('Always Glow Behind Map Icons'); end,
                desc = function() return l10n('Draw a glow texture behind map icons, colored unique to each quest.'); end,
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
                name = function() return l10n('Different Map Icon Color for Each Quest'); end,
                desc = function() return l10n('Show map icons with colors that are randomly generated based on quest ID.'); end,
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
                name = function() return l10n('Map Note Options'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(2.1),
            globalScale = {
                type = "range",
                order = 2.2,
                name = function() return l10n('Global Scale for Map Icons'); end,
                desc = function() return l10n('How large the Map Icons are. ( Default: %s )', optionsDefaults.global.globalScale); end,
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
                name = function() return l10n('Scale for Available/Complete Icons'); end,
                desc = function() return l10n('How large the available/complete icons are. ( Default: %s )', optionsDefaults.global.availableScale); end,
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
                name = function() return l10n('Scale for Event Icons'); end,
                desc = function() return l10n('How large the event icons are.  ( Default: %s )', optionsDefaults.global.eventScale); end,
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
                name = function() return l10n('Scale for Loot Icons'); end,
                desc = function() return l10n('How large the loot icons are.  ( Default: %s )', optionsDefaults.global.lootScale); end,
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
                name = function() return l10n('Scale for Slay Icons'); end,
                desc = function() return l10n('How large the slay icons are.  ( Default: %s )', optionsDefaults.global.monsterScale); end,
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
                name = function() return l10n('Scale for Object Icons'); end,
                desc = function() return l10n('How large the object icons are.  ( Default: %s )', optionsDefaults.global.objectScale); end,
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
                name = function() return l10n('Map and Cursor Coordinates'); end,
            },
            mapCoordinatesEnabled = {
                type = "toggle",
                order = 3.2,
                name = function() return l10n('Player and Cursor Coordinates'); end,
                desc = function() return l10n("Place the Player's coordinates and Cursor's coordinates on the Map's title."); end,
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
                name = function() return l10n('Map Coordinates Decimal Precision'); end,
                desc = function() return l10n('How many decimals to include in the precision on the Map for Player and Cursor coordinates. ( Default: %s )', optionsDefaults.global.mapCoordinatePrecision); end,
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
