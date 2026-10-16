---Draws the paths around the player as MinimapCanvas' paths layer, lined up with Questie's minimap
---icons, and hovers them.
---@class WaypointMinimap
local WaypointMinimap = QuestieLoader:CreateModule("WaypointMinimap")

---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type WaypointGeometry
local WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
---@type WaypointRenderer
local WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")
---@type WaypointHover
local WaypointHover = QuestieLoader:ImportModule("WaypointHover")
---@type MinimapCanvas
local MinimapCanvas = QuestieLoader:ImportModule("MinimapCanvas")

---@class WaypointMinimapEntry
---@field view WaypointView? nil while no segment is within reach of the projection.
---@field projection MinimapProjection Projection the view was drawn with.
---@field targets WaypointMinimapTarget[] The view's runs, for hovering.

---A drawn run of a route, in projected units with y down.
---@class WaypointMinimapTarget : WaypointHitTarget
---@field path WaypointPath The copy of the route that shows.

---Projects the parts of a path that come within reach of the projection's origin, in minimap
---units relative to it. Consecutive segments in reach form one run, so they join; so do a closed
---path's last and first segments.
---@param world WaypointWorldPoint[]
---@param projection MinimapProjection
---@return table[][] runs
local function _Runs(world, projection)
    local reach = projection.reach
    local originX, originY = projection.originX, projection.originY
    local runs = {}
    local previous, run
    local startsAtFirst = false
    for i, point in ipairs(world) do
        -- A segment is in reach when its bounding box overlaps the reach square around the origin.
        if previous and math.max(previous.x, point.x) >= originX - reach and math.min(previous.x, point.x) <= originX + reach
            and math.max(previous.y, point.y) >= originY - reach and math.min(previous.y, point.y) <= originY + reach then
            if not run then
                local x, y = MinimapCanvas.Project(projection, previous.x, previous.y)
                run = {{x = x, y = y}}
                runs[#runs + 1] = run
                startsAtFirst = startsAtFirst or i == 2
            end
            local x, y = MinimapCanvas.Project(projection, point.x, point.y)
            run[#run + 1] = {x = x, y = y}
        else
            run = nil
        end
        previous = point
    end
    -- A closed path cut elsewhere would end where it starts and start again there, as two capped
    -- ends. The last run continues into the first instead, so its start stays a corner.
    local first, last = world[1], world[#world]
    if run and startsAtFirst and #runs > 1 and first.x == last.x and first.y == last.y then
        local firstRun = runs[1]
        for i = 2, #firstRun do run[#run + 1] = firstRun[i] end
        runs[1], runs[#runs] = run, nil
    end
    return runs
end

-- Paths layer
-- Nothing here takes mouse input or calls protected API. The canvas collects, draws and hovers the
-- layer from its own update.

---@type Frame The layer's container on the canvas: the renderer's canvas.
local container
---@type WaypointCanvasRenderer?
local renderer
---@type table<string, WaypointMinimapEntry> Drawn routes, including those out of view.
local entries = {}
---@type {path: WaypointPath, alpha: number}[] One copy of each route that should show, wherever it is.
local paths = {}
---@type WaypointView[] Views shown by the last publication.
local shown = {}
---@type WaypointMinimapTarget[] Runs of the shown views, for hovering.
local targets = {}
local setupFailed = false

---@param views WaypointView[]
local function _Publish(views)
    local show = {}
    for _, view in ipairs(views) do show[view] = true end
    for _, view in ipairs(shown) do
        if not show[view] then view:Hide() end
    end
    for _, view in ipairs(views) do
        if not view:IsShown() then view:Show() end
    end
    shown = views
end

---Returns the view of the path's route, drawn for the projection; nil while no segment is in reach.
---@param path WaypointPath
---@param alpha number
---@param projection MinimapProjection
---@return WaypointView?
local function _View(path, alpha, projection)
    local entry = entries[path.route]
    -- Line width is in minimap units.
    local style = {thickness = Questie.db.profile.waypointWidth, color = QuestieWaypoints.Color(path), alpha = alpha,
        frameLevel = container:GetFrameLevel()}
    if entry and entry.projection == projection then
        -- Restyling redraws only what changed: the color of a highlight, or of another copy of the
        -- route such as an NPC hostile in one quest, or the width and colors after a setting changed.
        if entry.view then renderer:Restyle(entry.view, style) end
        return entry.view
    end
    local runs = _Runs(path.world, projection)
    local view = entry and entry.view
    if runs[1] then
        view = renderer:Draw(view, runs, style)
    elseif view then
        renderer:Release(view)
        view = nil
    end
    local runTargets = {}
    for i, run in ipairs(runs) do
        runTargets[i] = {points = run, bounds = WaypointGeometry.Bounds(run), path = path}
    end
    entries[path.route] = {view = view, projection = projection, targets = runTargets}
    return view
end

---@type MinimapLayer
local layer = {
    ---Collects the routes that should show and releases the views of the others. Icons sharing a
    ---patrol, such as an NPC's quests, draw it once, as its highlighted copy, or else its most visible one.
    Collect = function()
        local routes = {}
        for path in pairs(QuestieWaypoints.paths) do
            local alpha = QuestieWaypoints.MinimapAlpha(path)
            if alpha then
                -- The highlighted copy first, then the most visible one: alpha is at most 1.
                local rank = alpha + (QuestieWaypoints.IsHighlighted(path) and 2 or 0)
                local best = routes[path.route]
                if not best or rank > best.rank then
                    routes[path.route] = {path = path, alpha = alpha, rank = rank}
                end
            end
        end
        paths = {}
        for _, item in pairs(routes) do paths[#paths + 1] = item end
        for route, entry in pairs(entries) do
            if not routes[route] then
                entries[route] = nil
                if entry.view then renderer:Release(entry.view) end
            end
        end
        return paths[1] ~= nil
    end,

    ---Draws the routes in reach and shows them; nil hides them until there is a position again.
    Draw = function(projection)
        if not projection then
            _Publish({})
            targets = {}
            return
        end
        local views, drawnTargets = {}, {}
        for _, item in ipairs(paths) do
            local path = item.path
            -- The bounds reject paths out of reach before any segment is projected.
            if MinimapCanvas.InReach(projection, path.instanceId, path.worldBounds) then
                local view = _View(path, item.alpha, projection)
                if view then
                    views[#views + 1] = view
                    -- The route's runs, now hovered as the copy that shows.
                    for _, target in ipairs(entries[path.route].targets) do
                        target.path = path
                        drawnTargets[#drawnTargets + 1] = target
                    end
                end
            end
        end
        _Publish(views)
        targets = drawnTargets
    end,

    ---Hovers the path within reach of the cursor as its NPC's minimap icon, so its tooltip shows
    ---however far away the icon is.
    Hover = function(x, y)
        local nearest = x and WaypointGeometry.Nearest(targets, x, y, WaypointHover.Radius())
        local path = nearest and nearest.path
        WaypointHover.Set("minimap", path, path and path.owner.minimapTwin)
        return path ~= nil
    end,

    ---Releases every drawing; views and textures stay pooled.
    Clear = function()
        entries, paths, shown, targets = {}, {}, {}, {}
        WaypointHover.Set("minimap", nil)
        renderer:Clear()
    end,
}

---Collects the paths again on the next update, after paths or their visibility changed. The
---minimap is optional: a failed setup is reported once and world map drawing continues.
function WaypointMinimap.Invalidate()
    if not renderer then
        if setupFailed or not Minimap then return end
        local created, result = pcall(function()
            local layerContainer, masks = MinimapCanvas.AddLayer("paths", layer)
            container = layerContainer
            return WaypointRenderer.New(layerContainer, masks)
        end)
        if not created then
            setupFailed = true
            Questie.Error("Waypoint minimap setup failed:", result)
            return
        end
        renderer = result
    end
    MinimapCanvas.Invalidate("paths")
end
