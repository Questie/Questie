---@class QuestieWaypoints
local QuestieWaypoints = QuestieLoader:CreateModule("QuestieWaypoints")

---@type WaypointGeometry
local WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
---@type WaypointMap
local WaypointMap = QuestieLoader:ImportModule("WaypointMap")
---@type WaypointMinimap
local WaypointMinimap = QuestieLoader:ImportModule("WaypointMinimap")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

QuestieWaypoints.DEFAULT_COLOR = {1, 0.72, 0, 0.5}
QuestieWaypoints.HOSTILE_COLOR = {1, 0.2, 0, 0.7}
QuestieWaypoints.HOVER_COLOR = {0.93, 0.46, 0.13, 0.8}

---An NPC's patrol on one map, drawn while its owning icon is.
---@class WaypointPath : WaypointPolyline
---@field owner IconFrame World map icon whose lifetime and visibility the path follows.
---@field data IconData The owner's data when added. A pooled owner showing something else has other data.
---@field color number[]
---@field highlighted boolean? The owner, or the path itself, is hovered.

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

local function _Changed()
    WaypointMap.Invalidate()
    WaypointMinimap.Invalidate()
end

local function _ToWorld(x, y, uiMapId)
    return HBD:GetWorldCoordinatesFromZone(x, y, uiMapId)
end

---Draws an NPC's patrols in one zone for as long as owner is loaded, following its visibility.
---@param owner IconFrame World map icon of the NPC in this zone.
---@param patrols CoordPair[][] The zone's waypoints, {{{x, y}, ...}, ...} in percentages.
---@param areaId AreaId
---@param color number[]? {r, g, b, a}; DEFAULT_COLOR when nil.
function QuestieWaypoints.Add(owner, patrols, areaId, color)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
    local data = owner.data
    if not uiMapId or not data then return end
    local polylines = WaypointGeometry.BuildPolylines(patrols, uiMapId, _ToWorld)
    if #polylines == 0 then return end

    local owned = pathsByOwner[owner] or {}
    pathsByOwner[owner] = owned
    local shared = data.waypointPaths or {}
    data.waypointPaths = shared
    for _, path in ipairs(polylines) do
        ---@cast path WaypointPath
        path.owner, path.data, path.color = owner, data, color or QuestieWaypoints.DEFAULT_COLOR
        owned[#owned + 1] = path
        shared[#shared + 1] = path
        QuestieWaypoints.paths[path] = true
    end
    _Changed()
end

---Releases the paths an icon owns; called when the icon unloads.
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

---Redraws paths whose icons changed visibility or fade: FakeHide, FakeShow, FadeOut and FadeIn on
---the world map icon, or on its minimap twin, which shares the data.
---@param icon IconFrame
function QuestieWaypoints.OwnerChanged(icon)
    local shared = icon.data and icon.data.waypointPaths
    if shared and shared[1] then _Changed() end
end

---@param path WaypointPath
---@return boolean
local function _IsOwned(path)
    return path.owner.data == path.data
end

---World map opacity of a path; nil while it should not show.
---@param path WaypointPath
---@return number?
function QuestieWaypoints.WorldMapAlpha(path)
    local owner = path.owner
    if not _IsOwned(path) or owner.hidden or (soloData and not soloData[path.data]) then return nil end
    return owner.faded and Questie.db.profile.iconFadeLevel or 1
end

---Minimap opacity of a path; nil while it should not show. Paths follow the owner's minimap
---twin, so minimap settings and hiding apply to them like to minimap icons.
---@param path WaypointPath
---@return number?
function QuestieWaypoints.MinimapAlpha(path)
    local twin = path.owner.minimapTwin
    if not _IsOwned(path) or not twin or twin.data ~= path.data or twin.hidden then return nil end
    return twin.faded and Questie.db.profile.iconFadeLevel or 1
end

---@param path WaypointPath
---@return number[] color {r, g, b, a}
function QuestieWaypoints.Color(path)
    return path.highlighted and QuestieWaypoints.HOVER_COLOR or path.color
end

---Highlights every path of an NPC, as when its icon or one of its paths is hovered.
---@param data IconData?
---@param highlighted boolean
function QuestieWaypoints.SetHighlighted(data, highlighted)
    local shared = data and data.waypointPaths
    if not shared then return end
    for _, path in ipairs(shared) do
        if (path.highlighted == true) ~= highlighted then
            path.highlighted = highlighted or nil
            WaypointMap.Restyle(path)
        end
    end
end

---Shows only the given NPCs' paths on the world map, as while the tracker flashes an objective.
---@param dataSet table<IconData, true>? nil shows every path again.
function QuestieWaypoints.SetSolo(dataSet)
    soloData = dataSet
    WaypointMap.Invalidate()
end
