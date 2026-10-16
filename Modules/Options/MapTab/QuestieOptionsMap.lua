-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.map = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local function _Get(info)
    return QuestieOptions:GetProfileValue(info)
end

local function _SetAndRefresh(info, value)
    QuestieOptions:SetProfileValue(info, value)
    QuestieWaypoints.Refresh()
end

-- Colors are stored as {r, g, b, a}.
local function _GetColor(info)
    return unpack(Questie.db.profile[info[#info]])
end

local function _SetColor(info, r, g, b, a)
    Questie.db.profile[info[#info]] = {r, g, b, a}
    QuestieWaypoints.Refresh()
end

local function _WaypointsDisabled()
    local profile = Questie.db.profile
    return not (profile.waypointMapEnabled or profile.waypointMinimapEnabled)
end

function QuestieOptions.tabs.map:Initialize()
    return {
        name = function() return l10n("Map"); end,
        type = "group",
        order = 2.5,
        args = {
            waypoint_header = {
                type = "header",
                order = 1,
                name = function() return l10n("Waypoints"); end,
            },
            waypointSpacer = {
                type = "description",
                order = 1.01,
                name = "",
                width = 0.06,
            },
            waypointMapEnabled = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n("Enable Map Waypoints"); end,
                desc = function() return l10n("Draws the patrol paths of the NPCs Questie shows on the world map."); end,
                width = 1.595,
                get = _Get,
                set = _SetAndRefresh,
            },
            waypointMinimapEnabled = {
                type = "toggle",
                order = 1.2,
                name = function() return l10n("Enable Minimap Waypoints"); end,
                desc = function() return l10n("Draws the patrol paths of the NPCs Questie shows on the minimap. Minimap icons must be enabled too."); end,
                width = 1.595,
                get = _Get,
                set = _SetAndRefresh,
            },
            waypoint_appearance_group = {
                type = "group",
                order = 2,
                inline = true,
                name = function() return l10n("Appearance"); end,
                disabled = _WaypointsDisabled,
                args = {
                    waypointWidth = {
                        type = "range",
                        order = 2.1,
                        name = function() return l10n("Line width"); end,
                        desc = function() return l10n("How wide patrol paths are drawn. (Default: %s)", optionsDefaults.profile.waypointWidth); end,
                        width = 1.595,
                        min = 1,
                        max = 10,
                        step = 0.5,
                        get = _Get,
                        set = _SetAndRefresh,
                    },
                    waypointOpacity = {
                        type = "range",
                        order = 2.2,
                        name = function() return l10n("Line opacity"); end,
                        desc = function()
                            return l10n("Scales the opacity of every patrol path, on top of the opacity of its color. (Default: %s)",
                                optionsDefaults.profile.waypointOpacity * 100 .. "%");
                        end,
                        width = 1.595,
                        min = 0.1,
                        max = 2,
                        step = 0.05,
                        isPercent = true,
                        get = _Get,
                        set = _SetAndRefresh,
                    },
                    waypointHighlight = {
                        type = "toggle",
                        order = 2.3,
                        name = function() return l10n("Highlight patrol paths on hover"); end,
                        desc = function() return l10n("Hovering an NPC's icon or one of its patrol paths draws all of its paths in the highlight color."); end,
                        width = "full",
                        get = _Get,
                        set = _SetAndRefresh,
                    },
                    waypointColor = {
                        type = "color",
                        order = 2.4,
                        name = function() return l10n("Patrol color"); end,
                        desc = function() return l10n("Color of patrol paths."); end,
                        hasAlpha = true,
                        get = _GetColor,
                        set = _SetColor,
                    },
                    waypointHostileColor = {
                        type = "color",
                        order = 2.5,
                        name = function() return l10n("Hostile patrol color"); end,
                        desc = function() return l10n("Color of the patrol paths of NPCs you fight, such as quest objectives."); end,
                        hasAlpha = true,
                        get = _GetColor,
                        set = _SetColor,
                    },
                    waypointHighlightColor = {
                        type = "color",
                        order = 2.6,
                        name = function() return l10n("Highlight color"); end,
                        desc = function() return l10n("Color of an NPC's patrol paths while its icon or one of its paths is hovered."); end,
                        hasAlpha = true,
                        disabled = function() return _WaypointsDisabled() or not Questie.db.profile.waypointHighlight; end,
                        get = _GetColor,
                        set = _SetColor,
                    },
                },
            },
            waypoint_advanced_group = {
                type = "group",
                order = 3,
                inline = true,
                name = function() return l10n("Advanced Options"); end,
                disabled = _WaypointsDisabled,
                args = {
                    waypointSmoothing = {
                        type = "range",
                        order = 3.1,
                        name = function() return l10n("Waypoint smoothing"); end,
                        desc = function()
                            return l10n("Rounds the corners of NPC patrol lines. Higher values round them more; 0 draws sharp corners. (Default: %s)",
                                optionsDefaults.profile.waypointSmoothing);
                        end,
                        width = 1.595,
                        min = 0,
                        max = 2,
                        step = 0.05,
                        get = _Get,
                        set = function(info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieWaypoints.Redraw()
                        end,
                    },
                },
            },
        },
    }
end
