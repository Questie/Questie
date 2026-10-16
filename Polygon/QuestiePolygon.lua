---@class QuestiePolygon
local QuestiePolygon = QuestieLoader:CreateModule("QuestiePolygon")

---@class PolygonMarker
---@field frame IconFrame World-map icon.
---@field entry PolygonObjectiveEntry
---@field cluster PolygonCluster?
---@field minimapIcons PolygonMinimapIcon[] Minimap icons: the cluster's marker position, or each of its listed objects.
---@field projectedViews PolygonProjectionCache? Coordinates only; native drawings belong to PolygonRenderCache.

---@class IconFrame
---@field polygonMarker PolygonMarker? QuestiePolygon's own: the marker this world map icon shows.
---@field polygonMinimapMarker PolygonMarker? QuestiePolygon's own: the marker whose cluster this minimap icon shows.

---@class PolygonMinimapIcon
---@field frame IconFrame Points back to its marker through frame.polygonMinimapMarker.
---@field point table? Spawn point whose metadata it shows; nil for a route marker's, which shares the map icon's data.

---@class PolygonProjectionCache
---@field outline table[] Original immutable outline identifying this cache's source geometry.
---@field sourceMapId number
---@field maps table<number, table[]> Complete immutable outlines in destination-map percentages.

---@class PolygonObjectiveEntry
---@field active boolean
---@field index ObjectiveIndex Canonical objective index; also the saved-visibility key.
---@field revision number Collection/build identity, invalidated by the next update.
---@field generation number Marker identity; progress-only updates keep it, so they never stop attaching routes.
---@field quest Quest
---@field objective QuestObjective
---@field markers PolygonMarker[]
---@field signature string? Sorted phase-filtered spawn coordinates; geometry is session-local.
---@field spawnList table? Source table behind the published geometry.
---@field phases table<number, boolean>? Phase visibility recorded while collecting that geometry.
---@field hovered IconFrame?
---@field previewed boolean? A quest log control is hovered; shows and highlights every cluster.
---@field previewSuppressed boolean? A click hid the areas while hovering; no preview until a hover starts again.
---@field nearby boolean? The player is inside one of its cluster extents; used only when areas are not shown on accept.
---@field building boolean? Replacement geometry is not shown while marker allocation yields.

---@type PolygonGeometry
local PolygonGeometry = QuestieLoader:ImportModule("PolygonGeometry")
---@type PolygonRenderer
local PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
---@type PolygonRenderCache
local PolygonRenderCache = QuestieLoader:ImportModule("PolygonRenderCache")
---@type PolygonNudging
local PolygonNudging = QuestieLoader:ImportModule("PolygonNudging")
---@type PolygonMinimap
local PolygonMinimap = QuestieLoader:ImportModule("PolygonMinimap")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type QuestieFrame
local QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
---@type WorldMapLayers
local WorldMapLayers = QuestieLoader:ImportModule("WorldMapLayers")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type MapIconTooltip
local MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
---@type table<QuestId, table<ObjectiveIndex, PolygonObjectiveEntry>>
local entries = {}
-- Presentation objects survive resets; objective entries and pending callbacks do not.
local provider
---@type PolygonViewCache?
local renderCache
---@type PolygonNudgeLayout?
local nudging
---@type PolygonMinimapLayer?
local minimapLayer
local Provider = {}
local refreshPending = false
local nudgePending = false
local refreshEpoch = 0
local nearbyTicker
-- World units added around each cluster's spawn extent, so areas appear slightly before arrival.
local NEARBY_PADDING = 100

---Whether the player chose Questie blobs as the objective style. Objectives take the polygon path
---whenever it is chosen, also while Questie or its objectives are switched off: the path then draws
---nothing, where ordinary icons drawn meanwhile would show beside the areas once switched on again.
---@return boolean
function QuestiePolygon.IsChosen()
    return Questie.db.profile.enableQuestiePolygons == true
end

---Whether quest areas draw now: chosen, with Questie and its objectives switched on.
---@return boolean
function QuestiePolygon.IsEnabled()
    local profile = Questie.db.profile
    return QuestiePolygon.IsChosen() and profile.enableObjectives ~= false and profile.enabled ~= false
end

-- Area visibility
-- Questie.db.char.polygon.objectiveVisibility[questId][objectiveIndex] stores the player's
-- explicit choice: true shows the objective's areas and false hides them. nil follows the
-- automatic mode. Choices for finished quests are not pruned; each quest has few keys.
---@param entry PolygonObjectiveEntry
---@return boolean?
local function _SavedVisibility(entry)
    local quests = Questie.db.char.polygon.objectiveVisibility[entry.quest.Id]
    if quests then return quests[entry.index] end
end

---Automatic mode shows every objective's areas from quest accept, or, when the player
---disables that option, only while they are near one of the objective's clusters.
---@param entry PolygonObjectiveEntry
---@return boolean
local function _IsAutomaticallyShown(entry)
    return Questie.db.profile.showPolygonsOnAccept ~= false or entry.nearby == true
end

---@param entry PolygonObjectiveEntry
---@return boolean
local function _IsAreaShown(entry)
    local saved = _SavedVisibility(entry)
    if saved ~= nil then return saved end
    return _IsAutomaticallyShown(entry)
end

---RGB shared by an objective's fills, borders, and quest log controls.
---@param entry PolygonObjectiveEntry
---@return number[]
local function _AreaColor(entry)
    return entry.objective.Color or entry.quest.Color or {1, 0.72, 0}
end

-- Quest log controls on each client mirror area visibility. Marker clicks, proximity,
-- options, rebuilds, and removal coalesce into one next-frame notification.
---@type fun()[]
local visibilityCallbacks = {}
local visibilityNotifyPending = false

local function _NotifyVisibilityChanged()
    if visibilityNotifyPending or not next(visibilityCallbacks) then return end
    visibilityNotifyPending = true
    C_Timer.After(0, function()
        visibilityNotifyPending = false
        for _, callback in ipairs(visibilityCallbacks) do callback() end
    end)
end

---Saves what the objective should show. A choice matching the automatic mode clears the
---saved value instead, so the objective follows that mode again.
---@param entry PolygonObjectiveEntry
---@param shown boolean
local function _SaveVisibility(entry, shown)
    local visibility = Questie.db.char.polygon.objectiveVisibility
    local quests = visibility[entry.quest.Id] or {}
    if shown == _IsAutomaticallyShown(entry) then
        quests[entry.index] = nil
    else
        quests[entry.index] = shown
    end
    visibility[entry.quest.Id] = next(quests) and quests or nil
    -- Clicks arrive while hovering a marker or quest log control. The hover stays, so showing
    -- the areas again highlights them at once, but hidden areas are not previewed beneath the
    -- cursor until the next hover starts.
    entry.previewSuppressed = not shown or nil
    QuestiePolygon.ScheduleRefresh()
    _NotifyVisibilityChanged()
end

-- Marker layout and visible-set selection
-- Original map locations define the stacks. Hidden, queued, and offscreen members
-- retain their slots so scrolling and temporary visibility changes cannot rearrange icons.
function QuestiePolygon.UpdateNudging()
    if not nudging then return end
    local currentMarkers = {}
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            if entry.active and not entry.building and not entry.objective.Completed
                and QuestiePlayer.currentQuestlog[entry.quest.Id] == entry.quest then
                for _, marker in ipairs(entry.markers) do
                    local frame = marker.frame
                    if frame.polygonMarker == marker and frame.data and not frame.miniMapIcon then
                        currentMarkers[#currentMarkers + 1] = marker
                    end
                end
            end
        end
    end
    local map = provider and provider.owningMap
    nudging:SetEnabled(map ~= nil and map:IsShown() and QuestiePolygon.IsEnabled())
    nudging:Update(currentMarkers, Questie.db.profile.globalScale or 0.7)
end

-- Coalesce membership/size changes; HBD acquisition and zoom callbacks only reapply stored slots.
function QuestiePolygon.ScheduleNudging()
    if not nudging or not provider or not provider.owningMap or nudgePending then return end
    nudgePending = true
    local scheduledEpoch = refreshEpoch
    C_Timer.After(0, function()
        if refreshEpoch ~= scheduledEpoch then return end
        nudgePending = false
        QuestiePolygon.UpdateNudging()
    end)
end

---Selects eligible outlines and appearance; PolygonRenderCache owns native view reuse.
---Saved or automatic visibility cannot override the owning marker's hiding policy.
function QuestiePolygon.Refresh()
    if not renderCache then return end
    local map = provider and provider.owningMap
    if not map or not map:IsShown() or not QuestiePolygon.IsEnabled() then
        renderCache:Hide()
        return
    end

    local mapId = map:GetMapID()
    local mapData = HBD.mapData and HBD.mapData[mapId]
    local mapType = mapData and mapData.mapType
    -- Markers may appear on overview maps, but polygon drawing is only for detailed views.
    if mapType ~= Enum.UIMapType.Zone and mapType ~= Enum.UIMapType.Dungeon and mapType ~= Enum.UIMapType.Micro then
        renderCache:Hide()
        return
    end

    -- Build the complete desired set. Omitted views are hidden, not evicted.
    local shapes = {}
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            local previewing = (entry.hovered or entry.previewed) and not entry.previewSuppressed
            if entry.active and not entry.building and (previewing or _IsAreaShown(entry)) then
                for _, marker in ipairs(entry.markers) do
                    local frame = marker.frame
                    local outline = marker.cluster and marker.cluster.outline
                    local parent = frame:GetParent()
                    -- IsVisible includes native parent visibility. The wrapper check also rejects
                    -- queued or released icons reparented to UIParent, even while UIParent is shown.
                    if outline and frame.data and frame._loaded and frame.polygonMarker == marker and frame:IsVisible()
                        and parent and parent.pinTemplate == "HereBeDragonsPinsTemplateQuestie" and parent.icon == frame
                        and not frame.hidden and not frame._hidden_by_flash and not frame:ShouldBeHidden() then
                        local alpha = frame.texture.a or 1
                        if alpha > 0 then
                            local sourceMapId = marker.cluster.uiMapId
                            local points = outline
                            -- Source maps borrow the original outline. Other maps cache coordinates
                            -- separately from the retained frames managed by PolygonRenderCache.
                            if sourceMapId ~= mapId then
                                local cache = marker.projectedViews
                                if not cache or cache.outline ~= outline or cache.sourceMapId ~= sourceMapId then
                                    cache = {outline = outline, sourceMapId = sourceMapId, maps = {}}
                                    marker.projectedViews = cache
                                end
                                points = cache.maps[mapId]
                                if not points then
                                    -- Project geography, never the nudged marker anchor. Out-of-bounds
                                    -- vertices remain intact for canvas clipping and geometric hover.
                                    points = {}
                                    for i, point in ipairs(outline) do
                                        local x, y = HBD:TranslateZoneCoordinates(point.x / 100, point.y / 100,
                                            sourceMapId, mapId, true)
                                        local secretCoordinates = issecretvalue and (issecretvalue(x) or issecretvalue(y))
                                        if secretCoordinates or type(x) ~= "number" or type(y) ~= "number" then
                                            points = nil
                                            break
                                        end
                                        x, y = x * 100, y * 100
                                        if not (x > -math.huge and x < math.huge and y > -math.huge and y < math.huge) then
                                            points = nil
                                            break
                                        end
                                        points[i] = {x = x, y = y}
                                    end
                                    -- Publish only complete conversions; unavailable views can retry later.
                                    cache.maps[mapId] = points
                                end
                            end
                            if points then
                                local color = _AreaColor(entry)
                                shapes[#shapes + 1] = {
                                    owner = entry, key = marker, source = outline, sourceMapId = sourceMapId,
                                    points = points,
                                    color = {color[1], color[2], color[3], 0.25 * alpha},
                                    borderAlpha = 0.75 * alpha,
                                    highlighted = entry.hovered == frame or entry.previewed == true,
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    local canvas = map:GetCanvas()
    local level = WorldMapLayers.FrameLevel("areas")
    local _, err = renderCache:Present(mapId, shapes, canvas:GetWidth(), canvas:GetHeight(), level)
    if err then Questie.Error("Polygon drawing failed:", err) end
    -- Areas drawn anew may lie differently under a still cursor.
    WorldMapLayers.Invalidate("areas")
end

-- Minimap areas
-- The minimap shows what the world map would show. Quest log and tracker previews reach it,
-- highlighted; hovering a world-map marker previews only on the world map. Areas follow their
-- minimap icons' hiding rules, so the minimap icon switch governs them. Fade comes from the map
-- marker, such as tracker focus: minimap icons' own opacity fades with the player's distance.
-- Visibility is never required: a closed map shows no markers, and queued icons may load
-- without any notification.

---@return PolygonMinimapArea[]
local function _CollectMinimapAreas()
    local areas = {}
    if not QuestiePolygon.IsEnabled() then return areas end
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            if entry.active and not entry.building and (entry.previewed or _IsAreaShown(entry)) then
                local color = _AreaColor(entry)
                for _, marker in ipairs(entry.markers) do
                    local frame, cluster = marker.frame, marker.cluster
                    local minimapIcon = marker.minimapIcons[1]
                    local icon = minimapIcon and minimapIcon.frame
                    local alpha = frame.texture and frame.texture.a or 1
                    if cluster and cluster.outline and frame.data and frame.polygonMarker == marker and alpha > 0
                        and icon and icon.data and icon.polygonMinimapMarker == marker
                        and not icon.hidden and not icon:ShouldBeHidden() then
                        areas[#areas + 1] = {key = marker, cluster = cluster, color = color, alpha = alpha,
                            highlighted = entry.previewed == true}
                    end
                end
            end
        end
    end
    return areas
end

-- Area tooltips
-- Hovering areas on the world map shows the map icon tooltip for their markers, Shift detail
-- included, with a swatch in each objective's area colour matching its line to its outline.
-- The tooltip belongs to the map's scroll container. WorldMapLayers offers the areas the cursor
-- beneath patrol paths and only over the bare map, so a path or an icon keeps its own tooltip, and
-- the area tooltip returns once the cursor is back on the areas alone.
local AREA_SWATCH = "|TInterface\\Addons\\Questie\\Icons\\quest-log-fill-r12.png:10:10:0:0:32:32:0:32:0:32:%d:%d:%d|t "

---@param icon IconFrame A current polygon marker's icon.
---@return string
local function _AreaSwatch(icon)
    local color = _AreaColor(icon.polygonMarker.entry)
    return string.format(AREA_SWATCH, math.floor(color[1] * 255 + 0.5), math.floor(color[2] * 255 + 0.5),
        math.floor(color[3] * 255 + 0.5))
end

local areaTooltipFailed = false -- Retried only once the hovered areas change.

---@param shapes PolygonCachedShape[] Hovered shapes; keys are marker records.
---@param changed boolean
local function _UpdateAreaTooltip(shapes, changed)
    local owner = WorldMapFrame.ScrollContainer
    -- The renderer also rechecks the last offered cursor after drawing anew, before the stack looks
    -- again, so ask again for the bare map. The gamepad UI shows map icon tooltips on a private
    -- tooltip: using GameTooltip from hover checks would taint it.
    if #shapes == 0 or Questie.db.profile.polygonAreaTooltips == false or QuestieCompat.GetMouseFocus() ~= owner
        or QuestieCompat.IsGamepadUIEnabled() then
        MapIconTooltip.Release(owner, GameTooltip)
        return
    end
    if not changed and (areaTooltipFailed or GameTooltip:IsOwned(owner) and GameTooltip:IsShown()) then return end
    areaTooltipFailed = false

    -- Each area's marker icon stands in for it; overlapping areas list their icons together.
    local icons, listed = {}, {}
    for _, shape in ipairs(shapes) do
        local marker = shape.key
        local frame = marker.frame
        if frame and frame.polygonMarker == marker and frame.data and not listed[frame] then
            listed[frame] = true
            icons[#icons + 1] = frame
        end
    end
    if #icons == 0 then
        MapIconTooltip.Release(owner, GameTooltip)
        return
    end
    -- The renderer reports hover from inside its update; an error escaping here would clear every area.
    local shown, err = pcall(MapIconTooltip.ShowForIcons, owner, icons, GameTooltip, _AreaSwatch)
    if not shown then
        areaTooltipFailed = true
        Questie.Error("Polygon area tooltip failed:", err)
        MapIconTooltip.Release(owner, GameTooltip)
    end
end

---Coalesces drawing requests until the next frame, when map and marker state is read.
---The epoch prevents callbacks from an earlier reset from touching a new pending batch.
---Every caller also marks the minimap's areas stale, whether or not the world map is open.
function QuestiePolygon.ScheduleRefresh()
    if minimapLayer then minimapLayer:Invalidate() end
    if not renderCache or not provider or not provider.owningMap or refreshPending then return end
    refreshPending = true
    local scheduledEpoch = refreshEpoch
    C_Timer.After(0, function()
        if refreshEpoch ~= scheduledEpoch then return end
        refreshPending = false
        QuestiePolygon.Refresh()
    end)
end

-- Map-provider presentation lifecycle
function Provider:OnAdded(map)
    self.owningMap = map
    nudging:SetEnabled(map:IsShown() and QuestiePolygon.IsEnabled())
end

function Provider:OnRemoved()
    self.owningMap = nil
    nudging:SetEnabled(false)
    local hidden, err = pcall(renderCache.Hide, renderCache)
    if not hidden then Questie.Error("Polygon hiding failed:", err) end
end

-- RefreshAllData presents immediately. Other provider and marker notifications
-- coalesce through ScheduleRefresh to catch later canvas and HBD visibility changes.
function Provider:RefreshAllData()
    QuestiePolygon.UpdateNudging()
    QuestiePolygon.Refresh()
end

function Provider:OnMapChanged()
    -- Old-map views must stay hidden until deferred visibility/projection checks finish.
    renderCache:Hide()
    nudging:Reapply()
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            entry.hovered = nil
        end
    end
    QuestiePolygon.ScheduleRefresh()
end

function Provider:OnCanvasSizeChanged()
    nudging:Reapply()
    QuestiePolygon.ScheduleRefresh()
end

function Provider:OnShow()
    QuestiePolygon.UpdateNudging()
    QuestiePolygon.ScheduleRefresh()
end

function Provider:OnHide()
    nudging:SetEnabled(false)
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            entry.hovered, entry.previewed = nil, nil
        end
    end
    renderCache:Hide()
end

-- Objective teardown
-- Callers invalidate the entry or advance its generation before releasing markers.
-- Release retained views before recycling icon frames; cache keys are marker records.

---Clearing each back-reference first keeps the icon's unload from notifying its marker again.
---@param marker PolygonMarker
local function _UnloadMinimapIcons(marker)
    local icons = marker.minimapIcons
    marker.minimapIcons = {}
    for _, icon in ipairs(icons) do
        icon.frame.polygonMinimapMarker = nil
        QuestieFramePool:UnloadFrame(icon.frame)
    end
end

local function _ReleaseMarkers(entry)
    if renderCache then
        local released, err = pcall(renderCache.Release, renderCache, entry)
        if not released then Questie.Error("Polygon release failed:", err) end
    end
    local markers = entry.markers
    entry.markers = {}
    for _, marker in ipairs(markers) do
        if nudging then nudging:Remove(marker.frame) end
        marker.frame.polygonMarker = nil
        QuestieFramePool:UnloadFrame(marker.frame)
        _UnloadMinimapIcons(marker)
    end
end

function QuestiePolygon.RemoveObjective(questId, objectiveIndex)
    local questEntries = entries[questId]
    local entry = questEntries and questEntries[objectiveIndex]
    if not entry then return end
    entry.active = false
    questEntries[objectiveIndex] = nil
    _ReleaseMarkers(entry)
    if not next(questEntries) then entries[questId] = nil end
    QuestiePolygon.ScheduleRefresh()
    QuestiePolygon.ScheduleNudging()
    _NotifyVisibilityChanged()
end

function QuestiePolygon.RemoveQuest(questId)
    local questEntries = entries[questId]
    if not questEntries then return end
    entries[questId] = nil
    for _, entry in pairs(questEntries) do
        entry.active = false
        _ReleaseMarkers(entry)
    end
    QuestiePolygon.ScheduleRefresh()
    QuestiePolygon.ScheduleNudging()
    _NotifyVisibilityChanged()
end

function QuestiePolygon.Reset()
    refreshEpoch = refreshEpoch + 1
    refreshPending, nudgePending = false, false
    if nudging then nudging:Clear() end
    local oldEntries = entries
    entries = {}
    -- Invalidate every generation before native cleanup, which can fail. Stale
    -- waypoint jobs must not stay valid or skip marker teardown after that failure.
    for _, questEntries in pairs(oldEntries) do
        for _, entry in pairs(questEntries) do entry.active = false end
    end
    -- Release the whole drawing in one batch; failed native views remain owned by
    -- the renderer for a later retry, without preventing marker/provider teardown.
    if renderCache then
        local cleared, err = pcall(renderCache.Clear, renderCache)
        if not cleared then Questie.Error("Polygon cleanup failed:", err) end
    end
    if minimapLayer then
        local cleared, err = pcall(minimapLayer.Clear, minimapLayer)
        if not cleared then Questie.Error("Polygon minimap cleanup failed:", err) end
    end
    for _, questEntries in pairs(oldEntries) do
        for _, entry in pairs(questEntries) do _ReleaseMarkers(entry) end
    end
    if provider and provider.owningMap then
        provider.owningMap:RemoveDataProvider(provider)
    end
    _NotifyVisibilityChanged()
    -- WoW does not destroy native regions when their Lua wrappers become unreachable.
    -- Keep the detached provider and cleared cache/renderer so later mode/profile resets reuse their pools.
end

-- Marker interaction
-- Called through QuestieFrame's icon events, subscribed once, never as accumulating frame hooks.
function QuestiePolygon.MarkerRemoved(frame)
    local marker = frame.polygonMarker
    if not marker then return end
    if renderCache then
        local released, err = pcall(renderCache.Release, renderCache, marker.entry, marker)
        if not released then Questie.Error("Polygon release failed:", err) end
    end
    if nudging then nudging:Remove(frame) end
    frame.polygonMarker = nil
    marker.entry.hovered = nil
    for i, owned in ipairs(marker.entry.markers) do
        if owned == marker then
            table.remove(marker.entry.markers, i)
            break
        end
    end
    -- The cluster's minimap icons have no owner without it.
    _UnloadMinimapIcons(marker)
    QuestiePolygon.ScheduleRefresh()
    QuestiePolygon.ScheduleNudging()
    _NotifyVisibilityChanged()
end

---Drops a minimap icon that Questie's icon lifecycle unloaded; its marker stays.
---@param frame IconFrame
function QuestiePolygon.MinimapMarkerRemoved(frame)
    local marker = frame.polygonMinimapMarker
    if not marker then return end
    frame.polygonMinimapMarker = nil
    for i, icon in ipairs(marker.minimapIcons) do
        if icon.frame == frame then
            table.remove(marker.minimapIcons, i)
            break
        end
    end
    QuestiePolygon.ScheduleRefresh()
end

---Map markers affect drawing and stacking; minimap icons only decide minimap areas.
---@param frame IconFrame
function QuestiePolygon.MarkerChanged(frame)
    if frame.polygonMarker then
        QuestiePolygon.ScheduleRefresh()
        QuestiePolygon.ScheduleNudging()
    elseif frame.polygonMinimapMarker then
        QuestiePolygon.ScheduleRefresh()
    end
end

function QuestiePolygon.EnterMarker(frame)
    local marker = frame.polygonMarker
    if marker and marker.entry.active and not marker.entry.building and not frame.hidden and not frame:ShouldBeHidden() then
        marker.entry.hovered, marker.entry.previewSuppressed = frame, nil
        QuestiePolygon.ScheduleRefresh()
    end
end

function QuestiePolygon.LeaveMarker(frame)
    local marker = frame.polygonMarker
    if marker and marker.entry.hovered == frame then
        marker.entry.hovered = nil
        QuestiePolygon.ScheduleRefresh()
    end
end

---Shows the opposite of what the objective currently shows, ignoring the hover preview,
---for every cluster.
function QuestiePolygon.ToggleMarker(frame)
    local marker = frame.polygonMarker
    local entry = marker and marker.entry
    if entry and QuestiePolygon.IsEnabled() and entry.active and not entry.building
        and not entry.objective.Completed and not frame.hidden and not frame:ShouldBeHidden() then
        _SaveVisibility(entry, not _IsAreaShown(entry))
    end
end

---Follows markers and their minimap icons through QuestieFrame's icon events; each listener
---ignores icons that are not polygon markers.
local function _FollowIcons()
    QuestieFrame.Subscribe("Unload", function(frame)
        QuestiePolygon.MarkerRemoved(frame)
        QuestiePolygon.MinimapMarkerRemoved(frame)
    end)
    QuestieFrame.Subscribe("VisibilityChanged", QuestiePolygon.MarkerChanged)
    -- HereBeDragons can show a marker after the map provider has refreshed: recheck next frame, after
    -- native parenting and draw-queue bookkeeping settle. Minimap icons' native visibility decides nothing.
    QuestieFrame.Subscribe("NativeVisibilityChanged", function(frame)
        if frame.polygonMarker then QuestiePolygon.ScheduleRefresh() end
    end)
    QuestieFrame.Subscribe("HoverStart", QuestiePolygon.EnterMarker)
    -- A recycled icon's old marker ended its preview when it unloaded; a new marker's is not this hover's.
    QuestieFrame.Subscribe("HoverEnd", function(frame, data)
        if frame.data == data then QuestiePolygon.LeaveMarker(frame) end
    end)
    QuestieFrame.Subscribe("Click", QuestiePolygon.ToggleMarker)
end

-- Nearby mode
-- A coarse rectangle test is enough: it only decides whether to show approximate areas.
-- Clusters without outlines still count, since their spawns are part of the objective.
-- UnitPosition has no position inside instances, so nothing counts as nearby there.
---@param entry PolygonObjectiveEntry
---@param x number? Player world position from HBD.
---@param y number?
---@param instanceId number?
---@return boolean
local function _IsPlayerNearby(entry, x, y, instanceId)
    if x == nil or y == nil then return false end
    for _, marker in ipairs(entry.markers) do
        local cluster = marker.cluster
        local bounds = cluster and cluster.worldBounds
        if bounds and cluster.instanceId == instanceId
            and x >= bounds.minX - NEARBY_PADDING and x <= bounds.maxX + NEARBY_PADDING
            and y >= bounds.minY - NEARBY_PADDING and y <= bounds.maxY + NEARBY_PADDING then
            return true
        end
    end
    return false
end

---Recomputes which objectives the player is near and redraws when any area enters or leaves.
---Inert while areas show on accept; saved choices take precedence in _IsAreaShown either way.
function QuestiePolygon.UpdateNearby()
    if Questie.db.profile.showPolygonsOnAccept ~= false or not QuestiePolygon.IsEnabled() then return end
    local x, y, instanceId = HBD:GetPlayerWorldPosition()
    local changed = false
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            local nearby = _IsPlayerNearby(entry, x, y, instanceId)
            if entry.nearby ~= nearby then
                entry.nearby = nearby
                changed = true
            end
        end
    end
    if changed then
        QuestiePolygon.ScheduleRefresh()
        _NotifyVisibilityChanged()
    end
end

---Applies a changed automatic-mode option without rebuilding geometry.
function QuestiePolygon.RefreshVisibility()
    QuestiePolygon.UpdateNearby()
    QuestiePolygon.ScheduleRefresh()
    _NotifyVisibilityChanged()
end

-- Quest log controls
-- Client-neutral area state for quest log UIs. Each client's quest log integration lives in
-- its own file and reads or writes visibility only through these functions.

---Objectives whose clusters are all point markers have nothing to show or hide.
---@param entry PolygonObjectiveEntry
---@return boolean
local function _HasAreas(entry)
    for _, marker in ipairs(entry.markers) do
        if marker.cluster and marker.cluster.outline then return true end
    end
    return false
end

---@param questId QuestId
---@param objectiveIndex ObjectiveIndex
---@return PolygonObjectiveEntry?
local function _EntryWithAreas(questId, objectiveIndex)
    local questEntries = entries[questId]
    local entry = questEntries and questEntries[objectiveIndex]
    if entry and entry.active and not entry.building and QuestiePolygon.IsEnabled() and _HasAreas(entry) then
        return entry
    end
end

---@param questId QuestId
---@param objectiveIndex ObjectiveIndex Questie's canonical objective.Index.
---@return boolean? shown Saved or automatic visibility, ignoring the hover preview; nil when the objective has no areas.
---@return number[]? color The objective's area RGB.
function QuestiePolygon.GetObjectiveAreaState(questId, objectiveIndex)
    local entry = _EntryWithAreas(questId, objectiveIndex)
    if entry then return _IsAreaShown(entry), _AreaColor(entry) end
end

---Applies a quest log choice with the same automatic-mode rule as marker clicks.
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex
---@param shown boolean
function QuestiePolygon.SetObjectiveAreaShown(questId, objectiveIndex, shown)
    local entry = _EntryWithAreas(questId, objectiveIndex)
    if entry then _SaveVisibility(entry, shown) end
end

---Applies one quest log choice to every objective of the quest that has areas, including
---special objectives that the quest log does not list.
---@param questId QuestId
---@param shown boolean
function QuestiePolygon.SetQuestAreasShown(questId, shown)
    for index, entry in pairs(entries[questId] or {}) do
        if _EntryWithAreas(questId, index) then _SaveVisibility(entry, shown) end
    end
end

---Previews an objective's areas from a quest log control, like hovering its marker, but
---highlights every cluster. Clearing works even after the objective lost its areas.
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex
---@param previewing boolean
function QuestiePolygon.SetObjectivePreview(questId, objectiveIndex, previewing)
    local entry
    if previewing then
        entry = _EntryWithAreas(questId, objectiveIndex)
    else
        entry = entries[questId] and entries[questId][objectiveIndex]
    end
    if entry and entry.previewed ~= (previewing or nil) then
        entry.previewed = previewing or nil
        if previewing then entry.previewSuppressed = nil end
        QuestiePolygon.ScheduleRefresh()
    end
end

---Calls `callback` on the next frame after any change to area state, coalescing bursts.
---@param callback fun()
function QuestiePolygon.RegisterVisibilityCallback(callback)
    visibilityCallbacks[#visibilityCallbacks + 1] = callback
end

---Borrowed marker references for tracker highlighting, not another cleanup owner.
---@param objective QuestObjective
---@return IconFrame[]
function QuestiePolygon.GetObjectiveMarkers(objective)
    local frames = {}
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            if entry.active and not entry.building and entry.objective == objective then
                for _, marker in ipairs(entry.markers) do
                    if marker.frame.data and marker.frame.polygonMarker == marker then
                        frames[#frames + 1] = marker.frame
                    end
                end
            end
        end
    end
    return frames
end

-- Objective collection and generation publication

---Copies one spawn's presentation into icon metadata.
---@param data table
---@param quest Quest
---@param objective QuestObjective
---@param spawnData table
local function _SetSpawnData(data, quest, objective, spawnData)
    data.Name, data.ObjectiveTargetId = spawnData.Name, spawnData.Id
    data.Icon, data.IconColor = spawnData.Icon or objective.Icon, quest.Color
    data.GetIconScale, data.IconScale = spawnData.GetIconScale, spawnData.GetIconScale()
end

---@param quest Quest
---@param objective QuestObjective
---@param objectiveIndex ObjectiveIndex Canonical index.
---@param spawnData table
---@return table data
local function _IconData(quest, objective, objectiveIndex, spawnData)
    local data = {Id = quest.Id, ObjectiveIndex = objectiveIndex, QuestData = quest, ObjectiveData = objective,
        Type = objective.Type}
    _SetSpawnData(data, quest, objective, spawnData)
    return data
end

---Refreshes progress-only marker metadata while retaining geometry and route ownership.
---@param entry PolygonObjectiveEntry
---@param quest Quest
---@param objective QuestObjective
---@param pointsByKey table<string, table>? Points from a repeated collection; nil reuses each cluster's representative.
local function _RefreshMarkers(entry, quest, objective, pointsByKey)
    for _, marker in ipairs(entry.markers) do
        local frame = marker.frame
        local data = frame.data
        if data then
            data.QuestData, data.ObjectiveData = quest, objective
            local cluster = marker.cluster
            local point = cluster and (pointsByKey and pointsByKey[cluster.representative.key] or cluster.representative)
            if point then
                -- Later fast-path refreshes read the representative, so keep it on the current list.
                cluster.representative = point
                _SetSpawnData(data, quest, objective, point.spawnData)
            end
            local alpha = frame.texture.a
            frame:UpdateTexture(Questie.usedIcons[data.Icon])
            -- UpdateTexture resets the base size; cached markers skip ProcessQueue's map scaling.
            QuestieMap.utils.RescaleIcon(frame, QuestieMap.GetScaleValue())
            if alpha then
                local texture = frame.texture
                texture:SetVertexColor(texture.r, texture.g, texture.b, alpha)
            end
        end
        for _, minimapIcon in ipairs(marker.minimapIcons) do
            local iconFrame = minimapIcon.frame
            local iconData = iconFrame.data
            if iconData then
                iconData.QuestData, iconData.ObjectiveData = quest, objective
                local site = minimapIcon.point
                site = site and (pointsByKey and pointsByKey[site.key] or site)
                if site then
                    minimapIcon.point = site
                    _SetSpawnData(iconData, quest, objective, site.spawnData)
                end
                iconFrame:UpdateTexture(Questie.usedIcons[iconData.Icon])
                QuestieMap.utils.RescaleIcon(iconFrame)
                -- UpdateTexture clears a minimap icon's opacity; apply its distance fade at once
                -- rather than on the next fade tick, so the icon does not blink.
                iconFrame.lastGlowFade = nil
                if iconFrame.FadeLogic then iconFrame:FadeLogic() end
            end
        end
    end
    QuestiePolygon.ScheduleRefresh()
    QuestiePolygon.ScheduleNudging()
end

---Phase visibility is the only thing that changes an unchanged spawn list's eligible spawns.
---@param phases table<number, boolean> Visibility recorded while collecting the current geometry.
---@return boolean
local function _PhasesUnchanged(phases)
    for phase, visible in pairs(phases) do
        if (Phasing.IsSpawnVisible(phase) and true or false) ~= visible then return false end
    end
    return true
end

-- Objective routes
-- Each patrol of an objective's NPCs belongs to one of the objective's markers in its zone: the
-- cluster the NPC spawns in, so hovering either shows the other, else the zone's last marker.
-- QuestieWaypoints shows, fades and releases it with that marker's map icon. A zone only patrols
-- reach gets a route marker of its own, showing the patrolling NPC. Progress updates keep the
-- markers, and with them their routes.

---Allocation and route attachment stop once their markers are replaced or the objective is gone.
---Progress updates keep the generation, so they never stop attaching routes.
---@param entry PolygonObjectiveEntry
---@param generation number Marker generation the work started with.
---@return boolean
local function _IsCurrentGeneration(entry, generation)
    return entry.active and entry.generation == generation and QuestiePolygon.IsEnabled()
        and not entry.objective.Completed and QuestiePlayer.currentQuestlog[entry.quest.Id] == entry.quest
end

---Draws one of a marker's minimap icons.
---@param marker PolygonMarker
---@param data table
---@param point table? Spawn point the icon shows; nil for a route marker's.
---@param areaId AreaId
---@param x number
---@param y number
local function _DrawMinimapIcon(marker, data, point, areaId, x, y)
    local _, minimapFrame = QuestieMap:DrawWorldIcon(data, areaId, x, y, nil, nil, "minimap")
    if not minimapFrame then return end
    minimapFrame.polygonMinimapMarker = marker
    marker.minimapIcons[#marker.minimapIcons + 1] = {frame = minimapFrame, point = point}
end

---Draws a marker on both maps for a zone only the objective's patrols reach.
---@param entry PolygonObjectiveEntry
---@param spawnData table The patrolling NPC.
---@param areaId AreaId
---@param x number The patrol's first point in the zone, in percent.
---@param y number
---@return PolygonMarker? marker nil when the zone has no map.
local function _DrawRouteMarker(entry, spawnData, areaId, x, y)
    local data = _IconData(entry.quest, entry.objective, entry.index, spawnData)
    local frame = QuestieMap:DrawWorldIcon(data, areaId, x, y, nil, nil, "map")
    if not frame then return nil end
    local marker = {frame = frame, entry = entry, minimapIcons = {}}
    frame.polygonMarker = marker
    entry.markers[#entry.markers + 1] = marker
    _DrawMinimapIcon(marker, data, nil, areaId, x, y)
    return marker
end

---The marker whose cluster holds one of the NPC's spawns in the patrol's zone, so hovering the patrol
---outlines the area the NPC is in. Clusters are told apart by their spawn extent, as for nearby mode.
---@param entry PolygonObjectiveEntry
---@param spawnData table The patrolling NPC.
---@param areaId AreaId The patrol's zone.
---@return PolygonMarker? marker nil when no cluster in that zone holds a spawn of the NPC.
local function _RouteOwner(entry, spawnData, areaId)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
    local spawns = uiMapId and spawnData.Spawns and spawnData.Spawns[areaId]
    if not spawns then return nil end
    for _, spawn in ipairs(spawns) do
        local x, y = HBD:GetWorldCoordinatesFromZone(spawn[1] / 100, spawn[2] / 100, uiMapId)
        for _, marker in ipairs(entry.markers) do
            local cluster = marker.cluster
            local bounds = cluster and cluster.worldBounds
            -- World coordinates span the continent: a neighbouring zone's cluster may cover the spot.
            if x and y and bounds and cluster.uiMapId == uiMapId and x >= bounds.minX and x <= bounds.maxX
                and y >= bounds.minY and y <= bounds.maxY then
                return marker
            end
        end
    end
    return nil
end

---Draws each of the objective's patrols for a marker in its zone, adding route markers where no
---cluster is. Without any marker nothing is drawn, as in normal mode.
---@async
---@param entry PolygonObjectiveEntry
---@param zoneMarkers table<AreaId, PolygonMarker> Markers just drawn; the last one of each zone, which owns patrols no cluster holds.
local function _AttachRoutes(entry, zoneMarkers)
    if not next(zoneMarkers) then return end
    local generation, attached = entry.generation, 0
    for _, spawnData in pairs(entry.objective.spawnList or {}) do
        for areaId, patrols in pairs(spawnData.Waypoints or {}) do
            local first = patrols[1] and patrols[1][1]
            if first then
                local marker = _RouteOwner(entry, spawnData, areaId) or zoneMarkers[areaId]
                -- -1, -1 stands for an instance, which has no point on the zone's map.
                if not marker and first[1] ~= -1 and first[2] ~= -1 then
                    marker = _DrawRouteMarker(entry, spawnData, areaId, first[1], first[2])
                    zoneMarkers[areaId] = marker
                end
                -- A marker Questie removed meanwhile may have handed its icon to another quest.
                if marker and marker.frame.polygonMarker == marker then
                    QuestieMap:DrawWaypoints(marker.frame, spawnData.TooltipKey, patrols, areaId, spawnData.Hostile)
                end
                attached = attached + 1
                if attached >= 30 then
                    attached = 0
                    coroutine.yield()
                    if not _IsCurrentGeneration(entry, generation) then return end
                end
            end
        end
    end
    QuestiePolygon.ScheduleNudging()
end

---Builds from the full phase-filtered spawn list, not the incremental icon list. Cached updates
---refresh the markers and keep their routes; new markers draw the objective's routes again.
---@param quest Quest
---@param objective QuestObjective
---@param objectiveIndex ObjectiveIndex Used only when objective.Index has not been assigned.
---@async
function QuestiePolygon.UpdateObjective(quest, objective, objectiveIndex)
    -- Special objectives share the passed index 0; their assigned Index is the cache identity.
    local canonicalIndex = objective.Index or objectiveIndex
    if not QuestiePolygon.IsEnabled() or objective.IsPartyObjective or objective.Completed
        or QuestiePlayer.currentQuestlog[quest.Id] ~= quest then
        QuestiePolygon.RemoveObjective(quest.Id, canonicalIndex)
        return
    end

    local questEntries = entries[quest.Id]
    if not questEntries then
        questEntries = {}
        entries[quest.Id] = questEntries
    end
    local entry = questEntries[canonicalIndex]
    if not entry then
        entry = {active = true, index = canonicalIndex, markers = {}, revision = 0, generation = 0}
        questEntries[canonicalIndex] = entry
    end
    entry.revision = entry.revision + 1
    entry.quest, entry.objective = quest, objective
    local revision = entry.revision
    local function isCancelled()
        return not entry.active or entry.revision ~= revision or not QuestiePolygon.IsEnabled()
            or objective.Completed or QuestiePlayer.currentQuestlog[quest.Id] ~= quest
    end

    -- Progress updates keep the objective's spawnList table: Questie replaces spawn lists
    -- whole and never edits them in place. With unchanged phases the eligible spawns are
    -- identical, so skip collection, which converts and stringifies every spawn.
    if entry.signature and entry.spawnList == objective.spawnList and _PhasesUnchanged(entry.phases) then
        _RefreshMarkers(entry, quest, objective)
        return
    end

    -- Collect the full eligible source set before comparing geometry signatures.
    -- Collection shares the frame's polygon budget with every other objective update.
    local work = PolygonGeometry.NewWork(isCancelled)
    local points, signatureParts, pointsByKey, phases = {}, {}, {}, {}
    for targetKey, spawnData in pairs(objective.spawnList or {}) do
        for areaId, spawns in pairs(spawnData.Spawns or {}) do
            for _, spawn in ipairs(spawns) do
                local phase = spawn[3]
                if phase ~= nil and phases[phase] == nil then
                    phases[phase] = Phasing.IsSpawnVisible(phase) and true or false
                end
                if phase == nil or phases[phase] then
                    local locations = {{areaId, spawn[1], spawn[2]}}
                    if spawn[1] == -1 and spawn[2] == -1 then
                        locations = ZoneDB:GetDungeonLocation(areaId) or {}
                    end
                    for _, location in ipairs(locations) do
                        local uiMapId = ZoneDB:GetUiMapIdByAreaId(location[1])
                        local x, y = location[2], location[3]
                        if uiMapId and type(x) == "number" and type(y) == "number"
                            and x >= 0 and x <= 100 and y >= 0 and y <= 100 then
                            local worldX, worldY, instanceId = HBD:GetWorldCoordinatesFromZone(x / 100, y / 100, uiMapId)
                            if worldX and worldY and instanceId then
                                local key = table.concat({tostring(targetKey), location[1], uiMapId, instanceId,
                                    x, y, worldX, worldY}, ":")
                                local point = {
                                    x = x, y = y, worldX = worldX, worldY = worldY,
                                    uiMapId = uiMapId, instanceId = instanceId, areaId = location[1],
                                    key = key, targetKey = targetKey, spawnData = spawnData,
                                    isObject = spawnData.IsObject == true,
                                }
                                points[#points + 1] = point
                                signatureParts[#signatureParts + 1] = key
                                pointsByKey[key] = point
                            end
                        end
                    end
                end
                if not PolygonGeometry.Checkpoint(work) then return end
            end
        end
    end
    if isCancelled() then return end
    table.sort(signatureParts)
    local signature = table.concat(signatureParts, "|")

    -- A new spawn list or phase change with the same eligible spawns keeps its geometry.
    if entry.signature == signature then
        entry.spawnList, entry.phases = objective.spawnList, phases
        _RefreshMarkers(entry, quest, objective, pointsByKey)
        return
    end

    -- Hide outlines until replacement geometry and markers are ready. Bumping the generation
    -- stops earlier route attachment before its marker frames can be recycled.
    entry.signature, entry.hovered, entry.building = nil, nil, true
    entry.generation = entry.generation + 1
    _ReleaseMarkers(entry)
    QuestiePolygon.ScheduleRefresh()
    local clusters = PolygonGeometry.Build(points, nil, isCancelled)
    if not clusters or isCancelled() then return end

    -- Lazily retain one provider, render cache/renderer, layout, and size-change hook across resets.
    if not provider then
        provider = CreateFromMixins(MapCanvasDataProviderMixin, Provider)
        local renderer = PolygonRenderer.New(WorldMapFrame:GetCanvas(), {onHover = _UpdateAreaTooltip})
        -- Areas draw beneath patrol paths and Questie's icons, and hover only where nothing above covers the map.
        WorldMapLayers.AddLayer("areas", {
            Hover = function(cursor)
                -- Outlines are in canvas percent.
                if not cursor then return renderer:Hover(nil, nil) end
                return renderer:Hover(cursor.x / cursor.width * 100, cursor.y / cursor.height * 100)
            end,
        })
        renderCache = PolygonRenderCache.New(renderer)
        nudging = PolygonNudging.New()
        -- Preference setters resize before writing their new value. Read configured
        -- widths on the next frame; this single retained hook is inert while detached.
        hooksecurefunc(QuestieMap, "RescaleIcons", QuestiePolygon.ScheduleNudging)
        -- The provider is created once, before the first marker.
        _FollowIcons()
        -- The minimap is optional: its failure must not stop world-map drawing.
        local created, layer = pcall(PolygonMinimap.New, Minimap, _CollectMinimapAreas)
        if created then
            minimapLayer = layer
        else
            Questie.Error("Polygon minimap setup failed:", layer)
        end
    end
    if not provider.owningMap then WorldMapFrame:AddDataProvider(provider) end

    -- One retained proximity check; it returns immediately unless nearby mode is active.
    if not nearbyTicker then nearbyTicker = C_Timer.NewTicker(1, QuestiePolygon.UpdateNearby) end

    -- Allocate markers with generation ownership before publishing this batch for hover or saved visibility.
    -- The minimap shows each cluster like the world map, except that object clusters show every
    -- listed object: those icons sit on the objects themselves.
    local zoneMarkers, drawn = {}, 0
    for _, cluster in ipairs(clusters) do
        local point = pointsByKey[cluster.representative.key]
        local data = _IconData(quest, objective, canonicalIndex, point.spawnData)
        local frame = QuestieMap:DrawWorldIcon(data, point.areaId, cluster.x, cluster.y, nil, nil, "map")
        if frame then
            local marker = {frame = frame, entry = entry, cluster = cluster, minimapIcons = {}}
            frame.polygonMarker = marker
            entry.markers[#entry.markers + 1] = marker
            zoneMarkers[point.areaId] = marker
            drawn = drawn + 1
            -- The marker already owns this batch, so cancellation during a yield releases it.
            for _, site in ipairs(cluster.locations or {point}) do
                local x, y = site.x, site.y
                if not cluster.locations then x, y = cluster.x, cluster.y end
                _DrawMinimapIcon(marker, _IconData(quest, objective, canonicalIndex, site.spawnData), site, site.areaId, x, y)
                drawn = drawn + 1
                if drawn >= 30 then
                    drawn = 0
                    coroutine.yield()
                    if isCancelled() then return end
                end
            end
        end
    end
    entry.building = nil
    entry.signature, entry.spawnList, entry.phases = signature, objective.spawnList, phases
    -- Replacement clusters can move; recheck now instead of waiting up to a second for the ticker.
    if Questie.db.profile.showPolygonsOnAccept == false then
        entry.nearby = _IsPlayerNearby(entry, HBD:GetPlayerWorldPosition())
    end
    _NotifyVisibilityChanged()
    QuestiePolygon.ScheduleNudging()
    QuestiePolygon.ScheduleRefresh()
    _AttachRoutes(entry, zoneMarkers)
end
