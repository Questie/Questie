---Registry of NPC patrol paths, and Questie's adapter to them. Questie's icons add and release
---paths; WaypointMap and WaypointMinimap read which paths show and how, and draw them.
---@class QuestieWaypoints
local QuestieWaypoints = QuestieLoader:CreateModule("QuestieWaypoints")

---@type QuestieFrame
local QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
---@type WaypointGeometry
local WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
---@type WaypointMap
local WaypointMap = QuestieLoader:ImportModule("WaypointMap")
---@type WaypointMinimap
local WaypointMinimap = QuestieLoader:ImportModule("WaypointMinimap")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

---@class IconData
---@field waypointPaths WaypointPath[]? QuestieWaypoints' own: patrol paths of the NPC, shared by all icons with this data.

---An NPC's patrol on one map, drawn while its owning icon is.
---@class WaypointPath : WaypointPolyline
---@field owner IconFrame World map icon whose lifetime and visibility the path follows.
---@field data IconData The owner's data when added. A pooled owner showing something else has other data.
---@field route string Whose patrol this is, in which area, and which part of it. Icons drawing the same
---NPC's patrols, such as one for each of his quests, give their paths the same routes, which draw once.
---@field hostile boolean? The NPC is fought, such as for an objective; its paths take the hostile color.
---@field highlighted boolean? Its NPC is hovered, on an icon or one of its paths, on either map.

-- Paths by owner, so unloading an icon releases exactly its own paths. Icon data can be shared
-- between icons, but each path has one owner.
---@type table<IconFrame, WaypointPath[]>
local pathsByOwner = {}

---Every live path. Read only; changed through Add and RemoveOwner.
---@type table<WaypointPath, true>
QuestieWaypoints.paths = {}

-- Data whose paths alone show on the world map while the tracker flashes an objective.
---@type table<IconData, true>?
local soloData

-- Both maps draw again on their next update.
local function _Changed()
    WaypointMap.Invalidate()
    WaypointMinimap.Invalidate()
end

-- Registration

local function _ToWorld(x, y, uiMapId)
    return HBD:GetWorldCoordinatesFromZone(x, y, uiMapId)
end

-- Paths follow their owners through QuestieFrame's icon events, from the first path on.
local followingIcons = false

local function _FollowIcons()
    followingIcons = true
    QuestieFrame.Subscribe("Unload", QuestieWaypoints.RemoveOwner)
    QuestieFrame.Subscribe("VisibilityChanged", QuestieWaypoints.OwnerChanged)
    QuestieFrame.Subscribe("HoverEnd", function(_, data) QuestieWaypoints.SetHighlighted(data, false) end)
end

---Draws an NPC's patrols in one zone for as long as owner is loaded, following its visibility.
---@param owner IconFrame World map icon of the NPC in this zone.
---@param entity string? Whose patrols these are, as Questie's tooltip keys: "m_<npcId>" or "o_<objectId>".
---Without one, the paths are the owner's alone and never share a route.
---@param patrols CoordPair[][] The zone's waypoints, {{{x, y}, ...}, ...} in percentages.
---@param areaId AreaId
---@param hostile boolean? The NPC is fought, such as for an objective.
function QuestieWaypoints.Add(owner, entity, patrols, areaId, hostile)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
    local data = owner.data
    if not uiMapId or not data then return end
    local polylines = WaypointGeometry.BuildPolylines(patrols, uiMapId, _ToWorld)
    if #polylines == 0 then return end
    if not followingIcons then _FollowIcons() end

    local owned = pathsByOwner[owner] or {}
    pathsByOwner[owner] = owned
    local shared = data.waypointPaths or {}
    data.waypointPaths = shared
    local routePrefix = (entity or tostring(owner)) .. ":" .. areaId .. ":"
    for i, path in ipairs(polylines) do
        ---@cast path WaypointPath
        path.owner, path.data, path.hostile = owner, data, hostile or nil
        path.route = routePrefix .. i
        owned[#owned + 1] = path
        shared[#shared + 1] = path
        QuestieWaypoints.paths[path] = true
    end
    _Changed()
end

---Releases the paths an icon owns; called through its Unload event.
---@param owner IconFrame
function QuestieWaypoints.RemoveOwner(owner)
    local owned = pathsByOwner[owner]
    if not owned then return end
    pathsByOwner[owner] = nil
    local removed = {}
    for _, path in ipairs(owned) do
        removed[path] = true
        QuestieWaypoints.paths[path] = nil
    end
    -- Icons sharing the data keep their own paths.
    for _, path in ipairs(owned) do
        local shared = path.data.waypointPaths
        if shared then
            for i = #shared, 1, -1 do
                if removed[shared[i]] then table.remove(shared, i) end
            end
        end
    end
    _Changed()
end

---Redraws paths whose icons were shown, hidden or faded, through the VisibilityChanged event: the
---world map icon's, or its minimap twin's, which shares the data.
---@param icon IconFrame
function QuestieWaypoints.OwnerChanged(icon)
    local shared = icon.data and icon.data.waypointPaths
    if shared and shared[1] then _Changed() end
end

-- How paths show, read by the maps while drawing

---@param path WaypointPath
---@return boolean
local function _IsOwned(path)
    return path.owner.data == path.data
end

---World map opacity of a path; nil while it should not show.
---@param path WaypointPath
---@return number?
function QuestieWaypoints.WorldMapAlpha(path)
    if not Questie.db.profile.waypointMapEnabled then return nil end
    local owner = path.owner
    if not _IsOwned(path) or owner.hidden or (soloData and not soloData[path.data]) then return nil end
    return owner.faded and Questie.db.profile.iconFadeLevel or 1
end

---Minimap opacity of a path; nil while it should not show. Paths follow the owner's minimap
---twin, so minimap settings and hiding apply to them like to minimap icons.
---@param path WaypointPath
---@return number?
function QuestieWaypoints.MinimapAlpha(path)
    local profile = Questie.db.profile
    if not profile.waypointMinimapEnabled then return nil end
    local twin = path.owner.minimapTwin
    if not _IsOwned(path) or not twin or twin.data ~= path.data or twin.hidden then return nil end
    return twin.faded and profile.iconFadeLevel or 1
end

---The minimap icons of the path's route: one for each copy that shows on the minimap, as for each of
---an NPC's quests.
---@param path WaypointPath
---@return IconFrame[]
function QuestieWaypoints.MinimapIcons(path)
    local icons = {}
    for copy in pairs(QuestieWaypoints.paths) do
        if copy.route == path.route and QuestieWaypoints.MinimapAlpha(copy) then
            icons[#icons + 1] = copy.owner.minimapTwin
        end
    end
    return icons
end

---A hovered path shows highlighted, unless the highlight setting is off. A highlighted copy of a
---route is the one drawn.
---@param path WaypointPath
---@return boolean
function QuestieWaypoints.IsHighlighted(path)
    return path.highlighted and Questie.db.profile.waypointHighlight or false
end

---The path's color setting, its alpha scaled by the opacity setting.
---@param path WaypointPath
---@return number[] color {r, g, b, a}
function QuestieWaypoints.Color(path)
    local profile = Questie.db.profile
    local color = QuestieWaypoints.IsHighlighted(path) and profile.waypointHighlightColor
        or path.hostile and profile.waypointHostileColor
        or profile.waypointColor
    return {color[1], color[2], color[3], math.min(1, color[4] * profile.waypointOpacity)}
end

-- Changes that redraw

---Draws every path again, after a waypoint setting changed.
function QuestieWaypoints.Refresh()
    _Changed()
end

---Highlights every path of an NPC, as when its icon or one of its paths is hovered.
---@param data IconData?
---@param highlighted boolean
function QuestieWaypoints.SetHighlighted(data, highlighted)
    local shared = data and data.waypointPaths
    if not shared then return end
    local changed = false
    for _, path in ipairs(shared) do
        if (path.highlighted == true) ~= highlighted then
            path.highlighted = highlighted or nil
            changed = true
        end
    end
    -- Both maps choose each route's copy again: a highlighted copy takes its route over, and once
    -- unhighlighted hands it back to the most visible one.
    if changed then _Changed() end
end

---Shows only the given NPCs' paths on the world map, as while the tracker flashes an objective.
---@param dataSet table<IconData, true>? nil shows every path again.
function QuestieWaypoints.SetSolo(dataSet)
    soloData = dataSet
    WaypointMap.Invalidate()
end
