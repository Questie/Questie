---@class PolygonRenderCache
local PolygonRenderCache = QuestieLoader:CreateModule("PolygonRenderCache")

---@class PolygonCachedShape : PolygonShape
---@field owner table Objective entry; explicit Release ends its rendered ownership.
---@field key table Marker record identifying one polygon generation; never a pooled icon frame.
---@field source table[] Immutable source-map outline; replacing it invalidates all destination views.
---@field sourceMapId number Original UI map ID.
-- points is an immutable source outline or destination projection. Mutating it in
-- place is unsupported: replace its identity so retained geometry can be invalidated.

---@class PolygonCachedView
---@field frame Frame Opaque renderer-owned handle.
---@field points table[] Immutable outline in destination-map percentages.
---@field width number Canvas logical width used for this view's native configuration.
---@field height number Canvas logical height used for this view's native configuration.

---@class PolygonCachedOutline
---@field source table[]
---@field sourceMapId number
---@field maps table<number, PolygonCachedView> Destination map ID to lazily configured view.

---@class PolygonViewCache
---@field renderer PolygonCanvasRenderer
---@field owners table<table, table<table, PolygonCachedOutline>> Objective entry -> marker record -> retained destinations.
local Cache = {}
Cache.__index = Cache

---Retains lazily rendered views across maps. The caller owns visibility policy and
---must explicitly Release removed/replaced owners; absence from Present only hides.
---@param renderer PolygonCanvasRenderer
---@return PolygonViewCache
function PolygonRenderCache.New(renderer)
    return setmetatable({renderer = renderer, owners = {}}, Cache)
end

-- Keep failed destinations reachable for retry, but do not let one failure skip siblings.
local function _ReleaseViews(renderer, outline)
    local firstError
    for mapId, view in pairs(outline.maps) do
        local ok, err = pcall(renderer.Release, renderer, view.frame)
        if ok then
            outline.maps[mapId] = nil
        elseif not firstError then
            firstError = err
        end
    end
    return firstError
end

---Reconciles one map's complete visible set; omitted polygons and other maps are
---hidden, not released. Publish the set after configuration/style updates succeed.
---Failure drops logical cache entries and attempts cleanup of all native ownership,
---including partial allocations. Native cleanup failures remain renderer-owned.
---@param mapId number Destination UI map.
---@param shapes PolygonCachedShape[]
---@param width number Canvas logical width.
---@param height number Canvas logical height.
---@param frameLevel number
---@return boolean? success True on publication; nil on configuration or cleanup failure.
---@return string? err
function Cache:Present(mapId, shapes, width, height, frameLevel)
    local renderer = self.renderer
    local ok, err = pcall(function()
        assert(type(mapId) == "number" and mapId > -math.huge and mapId < math.huge, "Invalid polygon destination map")
        assert(type(width) == "number" and width > 0 and width < math.huge
            and type(height) == "number" and height > 0 and height < math.huge, "Invalid polygon canvas extent")
        local visibleFrames = {}
        for _, shape in ipairs(shapes) do
            assert(type(shape.owner) == "table" and type(shape.key) == "table", "Polygon views require owner and key identities")
            assert(type(shape.source) == "table" and type(shape.points) == "table"
                and type(shape.sourceMapId) == "number" and shape.sourceMapId > -math.huge
                and shape.sourceMapId < math.huge, "Polygon views require source geometry and map identity")

            local owned = self.owners[shape.owner]
            if not owned then
                owned = {}
                self.owners[shape.owner] = owned
            end
            local outline = owned[shape.key]
            -- Source replacement invalidates every visited destination, not just
            -- this map. Canvas resize and projection replacement are local to a view.
            if outline and (outline.source ~= shape.source or outline.sourceMapId ~= shape.sourceMapId) then
                local releaseError = _ReleaseViews(renderer, outline)
                if releaseError then error(releaseError, 0) end
                owned[shape.key] = nil
                outline = nil
            end
            if not outline then
                outline = {source = shape.source, sourceMapId = shape.sourceMapId, maps = {}}
                owned[shape.key] = outline
            end
            local view = outline.maps[mapId]
            if not view then
                -- Create records native ownership before configuration can throw.
                -- Clear can recover even if no handle was returned to this cache.
                local frame = renderer:Create(shape, width, height, frameLevel)
                view = {frame = frame, points = shape.points, width = width, height = height}
                outline.maps[mapId] = view
            elseif view.points ~= shape.points or view.width ~= width or view.height ~= height then
                renderer:Configure(view.frame, shape, width, height, frameLevel)
                view.points, view.width, view.height = shape.points, width, height
            else
                -- Appearance records are recreated by callers. The renderer compares
                -- their scalar values and can restyle highlights without touching fills.
                renderer:Style(view.frame, shape, frameLevel)
            end
            visibleFrames[#visibleFrames + 1] = view.frame
        end
        -- One publication also reconciles direct-hover and marker highlights for the batch.
        renderer:SetVisibleFrames(visibleFrames)
    end)
    if not ok then
        -- A native cleanup failure must not escape Present's error contract. The
        -- renderer keeps failed resources owned so a later Clear can retry them.
        local cleaned, cleanupError = pcall(self.Clear, self)
        if not cleaned then return nil, tostring(err) .. "; cleanup failed: " .. tostring(cleanupError) end
        return nil, tostring(err)
    end
    return true
end

---Hides every visible view and stops hover polling without releasing configuration.
---Owners and destination views remain available for the next Present.
function Cache:Hide()
    self.renderer:SetVisibleFrames({})
end

---Releases all destination views for an objective owner, or only one polygon key.
---Call before recycling the owner's icon frames or replacing its geometry generation.
---Attempts every selected view before throwing the first native cleanup error;
---failed mappings stay owned for retry, while successful releases are removed.
---@param owner table
---@param key table?
function Cache:Release(owner, key)
    local owned = self.owners[owner]
    if not owned then return end
    local firstError
    if key then
        local outline = owned[key]
        if not outline then return end
        firstError = _ReleaseViews(self.renderer, outline)
        if not next(outline.maps) then owned[key] = nil end
    else
        for polygonKey, outline in pairs(owned) do
            local err = _ReleaseViews(self.renderer, outline)
            if not next(outline.maps) then owned[polygonKey] = nil end
            if err and not firstError then firstError = err end
        end
    end
    if not next(owned) then self.owners[owner] = nil end
    if firstError then error(firstError, 0) end
end

---Drops all logical ownership, including hidden views; renderer pools remain reusable.
---Native cleanup can throw; failed resources remain renderer-owned for a later Clear retry.
function Cache:Clear()
    self.owners = {}
    self.renderer:Clear()
end
