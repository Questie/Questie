---Draws the objective areas around the player as MinimapCanvas' areas layer: beneath patrol paths,
---lined up with Questie's minimap icons. Minimap areas don't hover.
---@class PolygonMinimap
local PolygonMinimap = QuestieLoader:CreateModule("PolygonMinimap")

---@type PolygonRenderer
local PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
---@type MinimapCanvas
local MinimapCanvas = QuestieLoader:ImportModule("MinimapCanvas")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

---@class PolygonMinimapArea
---@field key table Stable identity of one drawn area, such as its marker record.
---@field cluster PolygonCluster Source geometry; the outline is in cluster.uiMapId percentages.
---@field color number[] Area RGB.
---@field alpha number Marker fade in (0, 1], scaling fill and border opacity.
---@field highlighted boolean? Previewed from the quest log or tracker; drawn with a highlighted border.

---@class PolygonWorldOutline
---@field points table[] {x, y} in HereBeDragons world yards.
---@field bounds number[] {minX, minY, maxX, maxY}

---@class PolygonMinimapView
---@field frame Frame
---@field cluster PolygonCluster Geometry the frame was configured from.
---@field projection MinimapProjection Projection the frame was configured with.
---@field color number[] Area color the frame was styled with.
---@field alpha number Fade the frame was styled with.
---@field highlighted boolean? Highlight the frame was styled with.

---What the areas layer offers QuestiePolygon.
---@class PolygonMinimapLayer
---@field Invalidate fun() Collects the areas again on the next update, after quest, visibility or option changes.
---@field Clear fun() Releases every drawing; frames and textures stay pooled. Native cleanup failure throws after every view was attempted.

-- Same fill and border opacity as the world map's areas at full marker opacity.
local FILL_ALPHA, BORDER_ALPHA = 0.25, 0.75

-- Geometry
-- Clusters are immutable; rebuilt geometry arrives as new clusters, so the cache needs no
-- invalidation. false records a map without world data.
---@type table<PolygonCluster, PolygonWorldOutline|false>
local worldOutlines = setmetatable({}, {__mode = "k"})

---Converts a cluster's outline from its map's percentages to world yards. Each axis uses the
---zone's own extent in yards, so zones not drawn at exactly the map's 3:2 shape keep their true
---proportions, and the minimap needs only one scale.
---@param cluster PolygonCluster
---@return PolygonWorldOutline?
function PolygonMinimap.WorldOutline(cluster)
    local cached = worldOutlines[cluster]
    if cached ~= nil then return cached or nil end
    local points, minX, minY, maxX, maxY = {}, math.huge, math.huge, -math.huge, -math.huge
    for i, point in ipairs(cluster.outline) do
        local x, y = HBD:GetWorldCoordinatesFromZone(point.x / 100, point.y / 100, cluster.uiMapId)
        if not x or not y then
            worldOutlines[cluster] = false
            return nil
        end
        points[i] = {x = x, y = y}
        minX, minY, maxX, maxY = math.min(minX, x), math.min(minY, y), math.max(maxX, x), math.max(maxY, y)
    end
    cached = {points = points, bounds = {minX, minY, maxX, maxY}}
    worldOutlines[cluster] = cached
    return cached
end

-- Areas layer
-- Nothing here takes mouse input or calls protected API. The canvas collects and draws the layer
-- from its own update; areas have no Hover, so the canvas never reads the cursor for them.

---Adds the areas layer to the minimap's canvas. Drawing starts on the first Invalidate.
---@param collect fun(): PolygonMinimapArea[] Areas that should show, wherever they are.
---@return PolygonMinimapLayer
function PolygonMinimap.New(collect)
    ---@type table<table, PolygonMinimapView> By area key, including areas out of reach.
    local views = {}
    ---@type PolygonMinimapArea[]
    local areas = {}
    ---@type Frame[]? Published visible set; nil forces the next publication.
    local visible
    local container, renderer

    ---@param frames Frame[]
    local function _Publish(frames)
        if visible and #visible == #frames then
            local same = true
            for i, frame in ipairs(frames) do
                if visible[i] ~= frame then same = false; break end
            end
            if same then return end
        end
        renderer:SetVisibleFrames(frames)
        visible = frames
    end

    ---Returns the area's frame, configured for the projection and styled in its color.
    ---@param area PolygonMinimapArea
    ---@param world PolygonWorldOutline
    ---@param projection MinimapProjection
    ---@return Frame
    local function _View(area, world, projection)
        local view = views[area.key]
        local color, alpha, highlighted = area.color, area.alpha, area.highlighted == true
        if view and view.cluster == area.cluster and view.projection == projection and view.color == color
            and view.alpha == alpha and view.highlighted == highlighted then
            return view.frame
        end
        local shape = {color = {color[1], color[2], color[3], FILL_ALPHA * alpha}, borderAlpha = BORDER_ALPHA * alpha,
            highlighted = highlighted}
        local level = container:GetFrameLevel()
        if view and view.cluster == area.cluster and view.projection == projection then
            renderer:Style(view.frame, shape, level)
        else
            -- The renderer's percentages over a 100x100 extent are minimap units.
            local points = {}
            for i, point in ipairs(world.points) do
                local x, y = MinimapCanvas.Project(projection, point.x, point.y)
                points[i] = {x = x, y = y}
            end
            shape.points = points
            if view then
                renderer:Configure(view.frame, shape, 100, 100, level)
            else
                view = {frame = renderer:Create(shape, 100, 100, level)}
                views[area.key] = view
            end
        end
        view.cluster, view.projection, view.color, view.alpha, view.highlighted = area.cluster, projection, color, alpha,
            highlighted
        return view.frame
    end

    ---@type MinimapLayer
    local layer = {
        ---Collects the areas that should show and releases the views of the others.
        Collect = function()
            areas = collect()
            local current = {}
            for _, area in ipairs(areas) do current[area.key] = true end
            for key, view in pairs(views) do
                if not current[key] then
                    views[key] = nil
                    renderer:Release(view.frame)
                end
            end
            visible = nil
            return areas[1] ~= nil
        end,

        ---Shows the areas in reach of the projection's origin; nil hides them until there is a position again.
        Draw = function(projection)
            local frames = {}
            for _, area in ipairs(projection and areas or {}) do
                local world = PolygonMinimap.WorldOutline(area.cluster)
                if world and MinimapCanvas.InReach(projection, area.cluster.instanceId, world.bounds) then
                    frames[#frames + 1] = _View(area, world, projection)
                end
            end
            _Publish(frames)
        end,

        Clear = function()
            views, areas, visible = {}, {}, nil
            renderer:Clear()
            -- Collected again, so after a reset the canvas finds nothing to show and idles.
            MinimapCanvas.Invalidate("areas")
        end,
    }

    local masks
    container, masks = MinimapCanvas.AddLayer("areas", layer)
    renderer = PolygonRenderer.New(container, nil, masks)
    return {
        Invalidate = function() MinimapCanvas.Invalidate("areas") end,
        Clear = layer.Clear,
    }
end
