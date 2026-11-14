-------------------------
--Import modules.
-------------------------
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type WaypointRenderer
local WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")

QuestieOptionsEngine.tabs.map = { ... }
local optionsDefaults = QuestieOptionsDefaults:Load()

local function _Get(key)
    return function()
        return Questie.db.profile[key]
    end
end

local function _SetAndRefresh(key)
    return function(_, value)
        Questie.db.profile[key] = value
        QuestieWaypoints.Refresh()
    end
end

-- Colors are stored as {r, g, b, a}.
local function _GetColor(key)
    return function()
        return unpack(Questie.db.profile[key])
    end
end

local function _SetColor(key)
    return function(r, g, b, a)
        Questie.db.profile[key] = {r, g, b, a}
        QuestieWaypoints.Refresh()
    end
end

local function _WaypointsEnabled()
    local profile = Questie.db.profile
    return (profile.waypointMapEnabled or profile.waypointMinimapEnabled) and true or false
end

function QuestieOptionsEngine.tabs.map:Initialize()
    return {
        title = "Map",
        subtitle = "Map Options",
        order = 1.5,
        icon = 134269,
        items = {
            waypoint_header = {
                type = "divider",
                order = 1,
                title = "Waypoints",
            },
            waypointMapEnabled = {
                type = "checkbox",
                order = 1.1,
                title = "Enable Map Waypoints",
                tooltip = "Draws the patrol paths of the NPCs Questie shows on the world map.",
                width = "half",
                get = _Get("waypointMapEnabled"),
                set = _SetAndRefresh("waypointMapEnabled"),
            },
            waypointMinimapEnabled = {
                type = "checkbox",
                order = 1.2,
                title = "Enable Minimap Waypoints",
                tooltip = "Draws the patrol paths of the NPCs Questie shows on the minimap. Minimap icons must be enabled too.",
                width = "half",
                get = _Get("waypointMinimapEnabled"),
                set = _SetAndRefresh("waypointMinimapEnabled"),
            },
            waypoint_appearance_group = {
                type = "container",
                order = 2,
                title = "Appearance",
                enabled = _WaypointsEnabled,
                items = {
                    waypointWidth = {
                        type = "slider",
                        order = 2.1,
                        title = "Line width",
                        tooltip = {"How wide patrol paths are drawn. (Default: %s)", optionsDefaults.profile.waypointWidth},
                        width = "half",
                        min = 1,
                        max = 10,
                        step = 0.5,
                        get = _Get("waypointWidth"),
                        set = _SetAndRefresh("waypointWidth"),
                        enabled = _WaypointsEnabled,
                    },
                    waypointOpacity = {
                        type = "slider",
                        order = 2.2,
                        title = "Line opacity",
                        tooltip = {"Scales the opacity of every patrol path, on top of the opacity of its color. (Default: %s)", optionsDefaults.profile.waypointOpacity * 100 .. "%"},
                        width = "half",
                        min = 0.1,
                        max = 2,
                        step = 0.05,
                        get = _Get("waypointOpacity"),
                        set = _SetAndRefresh("waypointOpacity"),
                        enabled = _WaypointsEnabled,
                        isPercent = true,
                    },
                    waypointHighlight = {
                        type = "checkbox",
                        order = 2.3,
                        title = "Highlight patrol paths on hover",
                        tooltip = "Hovering an NPC's icon or one of its patrol paths draws all of its paths in the highlight color.",
                        width = "full",
                        get = _Get("waypointHighlight"),
                        set = _SetAndRefresh("waypointHighlight"),
                        enabled = _WaypointsEnabled,
                    },
                    waypointColor = {
                        type = "colorPicker",
                        order = 2.4,
                        title = "Patrol color",
                        tooltip = "Color of patrol paths.",
                        width = "third",
                        hasOpacity = true,
                        get = _GetColor("waypointColor"),
                        set = _SetColor("waypointColor"),
                        enabled = _WaypointsEnabled,
                    },
                    waypointHostileColor = {
                        type = "colorPicker",
                        order = 2.5,
                        title = "Hostile patrol color",
                        tooltip = "Color of the patrol paths of NPCs you fight, such as quest objectives.",
                        width = "third",
                        hasOpacity = true,
                        get = _GetColor("waypointHostileColor"),
                        set = _SetColor("waypointHostileColor"),
                        enabled = _WaypointsEnabled,
                    },
                    waypointHighlightColor = {
                        type = "colorPicker",
                        order = 2.6,
                        title = "Highlight color",
                        tooltip = "Color of an NPC's patrol paths while its icon or one of its paths is hovered.",
                        width = "third",
                        hasOpacity = true,
                        enabled = function()
                            return _WaypointsEnabled() and (Questie.db.profile.waypointHighlight == true)
                        end,
                        get = _GetColor("waypointHighlightColor"),
                        set = _SetColor("waypointHighlightColor"),
                    },
                },
            },
            waypoint_advanced_group = {
                type = "container",
                order = 3,
                title = "Advanced Options",
                enabled = _WaypointsEnabled,
                items = {
                    waypointSmoothing = {
                        type = "slider",
                        order = 3.1,
                        title = "Waypoint smoothing",
                        tooltip = {"Rounds the corners of NPC patrol lines. Higher values round them more; 0 draws sharp corners. (Default: %s)", optionsDefaults.profile.waypointSmoothing},
                        width = "half",
                        min = 0,
                        max = 2,
                        step = 0.05,
                        get = _Get("waypointSmoothing"),
                        set = function(_, value)
                            Questie.db.profile.waypointSmoothing = value
                            WaypointRenderer.RedrawAll()
                        end,
                        enabled = _WaypointsEnabled,
                    },
                },
            },
        },
    }
end