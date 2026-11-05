---Draws the paths of the shown world map onto its canvas, and hovers them as the world map's paths layer.
---@class WaypointMap
local WaypointMap = QuestieLoader:CreateModule("WaypointMap")

---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type WaypointGeometry
local WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
---@type WaypointRenderer
local WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")
---@type WaypointHover
local WaypointHover = QuestieLoader:ImportModule("WaypointHover")
---@type WorldMapLayers
local WorldMapLayers = QuestieLoader:ImportModule("WorldMapLayers")

---A route drawn on the current map, in canvas units with y down.
---@class WaypointMapView : WaypointHitTarget
---@field path WaypointPath The copy of the route that shows.
---@field view WaypointView
---@field mapId number The map, and its canvas size, the view was drawn for.
---@field width number
---@field height number
---@field alpha number

---@type WaypointCanvasRenderer?
local renderer
---@type Frame?
local driver
---@type table<string, WaypointMapView> By route.
local views = {}
---@type WaypointMapView[]
local visible = {}
-- Paths, their visibility or their highlight changed since the last draw.
local dirty = true
-- The map and canvas size drawn for. shownScale is the canvas scale line widths are drawn for;
-- currentScale the latest one.
local shownMapId, shownWidth, shownHeight, shownScale, currentScale

-- Drawing

---Line width and hover reach are in map UI units: both are divided by the canvas scale, so they
---keep their size on screen while zooming.
---@param path WaypointPath
---@param alpha number
---@return WaypointStyle
local function _Style(path, alpha)
    local profile = Questie.db.profile
    return {thickness = profile.waypointWidth / shownScale, color = QuestieWaypoints.Color(path), alpha = alpha,
        frameLevel = WorldMapLayers.FrameLevel("paths"), hoverRadius = profile.waypointDebugHover and WaypointHover.Radius() / shownScale or nil}
end

---Paths draw on their own map only. Several icons can own the same patrol, such as an NPC who
---starts three quests: each copy would draw the route again, darker where they stack. A route draws
---once, as its highlighted copy, or else its most visible one.
---@return table<string, {path: WaypointPath, alpha: number, rank: number}> By route.
local function _ShownRoutes()
    local routes = {}
    if not (shownWidth > 0 and shownHeight > 0) then return routes end
    for path in pairs(QuestieWaypoints.paths) do
        local alpha = path.uiMapId == shownMapId and QuestieWaypoints.WorldMapAlpha(path)
        if alpha then
            -- The highlighted copy first, then the most visible one: alpha is at most 1.
            local rank = alpha + (QuestieWaypoints.IsHighlighted(path) and 2 or 0)
            local best = routes[path.route]
            if not best or rank > best.rank then
                routes[path.route] = {path = path, alpha = alpha, rank = rank}
            end
        end
    end
    return routes
end

---Draws every route that shows on the current map and releases the others' views.
local function _Refresh()
    dirty = false
    local routes = _ShownRoutes()
    local list = {}
    for route, shown in pairs(routes) do
        local path, alpha = shown.path, shown.alpha
        local entry = views[route]
        if not entry or entry.mapId ~= shownMapId or entry.width ~= shownWidth or entry.height ~= shownHeight then
            local canvasPoints = {}
            for i, point in ipairs(path.points) do
                canvasPoints[i] = {x = point.x * shownWidth / 100, y = point.y * shownHeight / 100}
            end
            local view = renderer:Draw(entry and entry.view, {canvasPoints}, _Style(path, alpha))
            entry = {view = view, mapId = shownMapId, width = shownWidth, height = shownHeight,
                points = canvasPoints, bounds = WaypointGeometry.Bounds(canvasPoints)}
            views[route] = entry
        else
            renderer:Restyle(entry.view, _Style(path, alpha))
        end
        entry.path, entry.alpha = path, alpha
        entry.view:Show()
        list[#list + 1] = entry
    end
    for route, entry in pairs(views) do
        if not routes[route] then
            renderer:Release(entry.view)
            views[route] = nil
        end
    end
    visible = list
end

-- Hover
-- WorldMapLayers offers the cursor only over the bare map, above the areas and beneath Questie's
-- icons; paths take no mouse input.

---The path within hover reach of the cursor, the nearest where reaches overlap; nil until the paths
---are drawn for the cursor's map and canvas size.
---@param cursor WorldMapCursor
---@return WaypointMapView?
local function _PathAt(cursor)
    if not visible[1] or cursor.mapId ~= shownMapId or cursor.width ~= shownWidth or cursor.height ~= shownHeight then
        return nil
    end
    return WaypointGeometry.Nearest(visible, cursor.x, cursor.y, WaypointHover.Radius() / cursor.scale)
end

---@type WorldMapLayer
local layer = {
    Hover = function(cursor)
        local nearest = cursor and _PathAt(cursor)
        local path = nearest and nearest.path
        WaypointHover.Set("map", path, path and path.owner)
        return path ~= nil
    end,
}

-- Driver
-- One frame on the canvas runs while the map is open. It redraws after changes, map switches and
-- canvas resizes, and keeps line widths constant on screen while zooming.

-- Smooth zooming eases the canvas scale over many frames. Lines scale with the canvas meanwhile
-- and are redrawn once it settles, or sooner when their width drifts this far from the target.
local ZOOM_REDRAW_DRIFT = 0.25

local function _Update()
    local mapId = WorldMapFrame:GetMapID()
    local canvas = WorldMapFrame:GetCanvas()
    local width, height = canvas:GetWidth(), canvas:GetHeight()
    local scale = WorldMapFrame.ScrollContainer:GetCanvasScale()
    local settled = scale == currentScale
    currentScale = scale
    local changed = false
    if dirty or mapId ~= shownMapId or width ~= shownWidth or height ~= shownHeight then
        -- Paths changed, or the map or canvas did: draw again.
        shownMapId, shownWidth, shownHeight, shownScale = mapId, width, height, scale
        _Refresh()
        changed = true
    elseif scale ~= shownScale and (settled or math.abs(scale / shownScale - 1) > ZOOM_REDRAW_DRIFT) then
        -- A zoom settled or drifted far: restyle to the width on screen.
        shownScale = scale
        for _, entry in ipairs(visible) do
            renderer:Restyle(entry.view, _Style(entry.path, entry.alpha))
        end
        changed = true
    end
    -- Redrawn paths may lie differently under a still cursor; the stack notices zooming by itself.
    if changed then WorldMapLayers.Invalidate("paths") end
end

local function _CreateDriver()
    local canvas = WorldMapFrame:GetCanvas()
    renderer = WaypointRenderer.New(canvas)
    driver = CreateFrame("Frame", nil, canvas)
    driver:SetScript("OnUpdate", _Update)
    -- Closing the map ends the hover through the stack. Views stay drawn for reopening the same map.
    WorldMapLayers.AddLayer("paths", layer)
end

---Redraws on the next frame the map is open, after paths, their visibility or their highlight
---changed. Routes keep their drawn lines when only their style changes.
function WaypointMap.Invalidate()
    if not driver then _CreateDriver() end
    dirty = true
end
