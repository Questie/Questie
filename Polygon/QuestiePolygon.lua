---@class QuestiePolygon
local QuestiePolygon = QuestieLoader:CreateModule("QuestiePolygon")

---@class PolygonMarker
---@field frame IconFrame
---@field entry PolygonObjectiveEntry
---@field cluster PolygonCluster?

---@class PolygonObjectiveEntry
---@field active boolean
---@field revision number Collection/build identity, invalidated by the next update.
---@field generation number Marker/waypoint identity; progress-only updates do not cancel a current route batch.
---@field quest Quest
---@field objective QuestObjective
---@field markers PolygonMarker[]
---@field signature string? Sorted phase-filtered spawn coordinates; geometry is session-local.
---@field hovered IconFrame?
---@field pinned boolean?
---@field building boolean? Replacement geometry is not shown while marker allocation yields.

---@class PolygonObjectiveWork
---@field entry PolygonObjectiveEntry
---@field generation number Captured marker generation; never infer validity from a pooled frame reference.

---@type PolygonGeometry
local PolygonGeometry = QuestieLoader:ImportModule("PolygonGeometry")
---@type PolygonRenderer
local PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
---@type PolygonNudging
local PolygonNudging = QuestieLoader:ImportModule("PolygonNudging")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
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
local renderer
local nudging
local Provider = {}
local refreshPending = false
local nudgePending = false
local refreshEpoch = 0

function QuestiePolygon.IsEnabled()
    local profile = Questie.db.profile
    return profile.enableQuestiePolygons == true and profile.enableObjectives ~= false and profile.enabled ~= false
end

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

-- The map provider owns drawing only. Marker visibility remains Questie's policy;
-- a hidden/untracked objective cannot leave behind a pinned area.
function QuestiePolygon.Refresh()
    if not renderer then return end
    local map = provider and provider.owningMap
    if not map or not map:IsShown() or not QuestiePolygon.IsEnabled() then
        renderer:Clear()
        return
    end

    local shapes = {}
    local mapId = map:GetMapID()
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            if entry.active and not entry.building and (entry.pinned or entry.hovered) then
                for _, marker in ipairs(entry.markers) do
                    local frame = marker.frame
                    local outline = marker.cluster and marker.cluster.outline
                    if outline and frame.data and frame.UiMapID == mapId and not frame.hidden
                        and not frame._hidden_by_flash and not frame:ShouldBeHidden() then
                        local alpha = frame.texture.a or 1
                        if alpha > 0 then
                            local color = entry.objective.Color or entry.quest.Color or {1, 0.72, 0}
                            shapes[#shapes + 1] = {
                                points = outline,
                                color = {color[1], color[2], color[3], 0.25 * alpha},
                                borderAlpha = 0.75 * alpha,
                                highlighted = entry.hovered == frame,
                            }
                        end
                    end
                end
            end
        end
    end
    local canvas = map:GetCanvas()
    local level = map:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB")
    local _, err = renderer:Draw(shapes, canvas:GetWidth(), canvas:GetHeight(), level)
    if err then Questie.Error("Polygon drawing failed:", err) end
end

function QuestiePolygon.ScheduleRefresh()
    if not renderer or not provider or not provider.owningMap or refreshPending then return end
    refreshPending = true
    local scheduledEpoch = refreshEpoch
    C_Timer.After(0, function()
        if refreshEpoch ~= scheduledEpoch then return end
        refreshPending = false
        QuestiePolygon.Refresh()
    end)
end

function Provider:OnAdded(map)
    self.owningMap = map
    nudging:SetEnabled(map:IsShown() and QuestiePolygon.IsEnabled())
end

function Provider:OnRemoved()
    nudging:SetEnabled(false)
    renderer:Clear()
    self.owningMap = nil
end

function Provider:RefreshAllData()
    QuestiePolygon.UpdateNudging()
    QuestiePolygon.Refresh()
end

function Provider:OnMapChanged()
    nudging:Reapply()
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            entry.hovered = nil
        end
    end
    QuestiePolygon.Refresh()
end

function Provider:OnCanvasSizeChanged()
    nudging:Reapply()
    QuestiePolygon.Refresh()
end

function Provider:OnShow()
    QuestiePolygon.UpdateNudging()
    QuestiePolygon.Refresh()
end

function Provider:OnHide()
    nudging:SetEnabled(false)
    for _, questEntries in pairs(entries) do
        for _, entry in pairs(questEntries) do
            entry.hovered = nil
        end
    end
    renderer:Clear()
end

-- Geometry and markers have independent ownership. Invalidate before releasing frames,
-- so a yielding generator or deferred draw cannot republish this objective.
local function _ReleaseMarkers(entry)
    local markers = entry.markers
    entry.markers = {}
    for _, marker in ipairs(markers) do
        if nudging then nudging:Remove(marker.frame) end
        marker.frame.polygonMarker = nil
        QuestieFramePool:UnloadFrame(marker.frame)
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
end

function QuestiePolygon.Reset()
    refreshEpoch = refreshEpoch + 1
    refreshPending, nudgePending = false, false
    if nudging then nudging:Clear() end
    local oldEntries = entries
    entries = {}
    for _, questEntries in pairs(oldEntries) do
        for _, entry in pairs(questEntries) do
            entry.active = false
            _ReleaseMarkers(entry)
        end
    end
    if renderer then renderer:Clear() end
    if provider and provider.owningMap then
        provider.owningMap:RemoveDataProvider(provider)
    end
    -- WoW does not destroy native regions when their Lua wrappers become unreachable.
    -- Keep the detached provider and cleared renderer so later mode/profile resets reuse their pools.
end

-- Called by the existing icon lifecycle, never installed as accumulating frame hooks.
function QuestiePolygon.MarkerRemoved(frame)
    local marker = frame.polygonMarker
    if not marker then return end
    if nudging then nudging:Remove(frame) end
    frame.polygonMarker = nil
    marker.entry.hovered = nil
    for i, owned in ipairs(marker.entry.markers) do
        if owned == marker then
            table.remove(marker.entry.markers, i)
            break
        end
    end
    QuestiePolygon.ScheduleRefresh()
    QuestiePolygon.ScheduleNudging()
end

function QuestiePolygon.MarkerChanged(frame)
    if frame.polygonMarker then
        QuestiePolygon.ScheduleRefresh()
        QuestiePolygon.ScheduleNudging()
    end
end

function QuestiePolygon.EnterMarker(frame)
    local marker = frame.polygonMarker
    if marker and marker.entry.active and not marker.entry.building and not frame.hidden and not frame:ShouldBeHidden() then
        marker.entry.hovered = frame
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

function QuestiePolygon.ToggleMarker(frame)
    local marker = frame.polygonMarker
    if marker and QuestiePolygon.IsEnabled() and marker.entry.active and not marker.entry.building
        and not marker.entry.objective.Completed and not frame.hidden and not frame:ShouldBeHidden() then
        marker.entry.pinned = not marker.entry.pinned
        QuestiePolygon.ScheduleRefresh()
    end
end

---Waypoint work can yield after marker creation. Keep its generation separate from
---collection revisions so an unchanged progress update does not abandon half a route batch.
---@param work PolygonObjectiveWork?
---@return boolean
function QuestiePolygon.IsCurrentObjective(work)
    local entry = work and work.entry
    return entry ~= nil and entry.active and entry.generation == work.generation and QuestiePolygon.IsEnabled()
        and not entry.objective.Completed and QuestiePlayer.currentQuestlog[entry.quest.Id] == entry.quest
end

---Adopts a fallback map marker for this generation, or unloads it when the work is stale.
---@param frame IconFrame
---@param work PolygonObjectiveWork?
---@return boolean accepted
function QuestiePolygon.OwnWaypointMarker(frame, work)
    if not QuestiePolygon.IsCurrentObjective(work) then
        QuestieFramePool:UnloadFrame(frame)
        return false
    end
    local entry = work.entry
    local marker = {frame = frame, entry = entry}
    frame.polygonMarker = marker
    entry.markers[#entry.markers + 1] = marker
    QuestiePolygon.ScheduleNudging()
    return true
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

---Builds from the full phase-filtered spawn list, not the incremental icon list.
---Returns newly drawn marker/zone owners for existing waypoint creation; cached updates
---return no new owners, preventing duplicate waypoint frames. The third return carries
---generation ownership for both minimap fallback pins and world-map route creation.
---@param quest Quest
---@param objective QuestObjective
---@param objectiveIndex ObjectiveIndex Used only when objective.Index has not been assigned.
---@async
---@return table? icon Representative metadata for waypoint fallback pins; nil when no new markers were drawn.
---@return table<AreaId, table> iconPerZone Newly drawn route owners as {frame, x, y}, with original percentage coordinates.
---@return PolygonObjectiveWork? waypointWork
function QuestiePolygon.UpdateObjective(quest, objective, objectiveIndex)
    -- Special objectives share the passed index 0; their assigned Index is the cache identity.
    local canonicalIndex = objective.Index or objectiveIndex
    if not QuestiePolygon.IsEnabled() or objective.IsPartyObjective or objective.Completed
        or QuestiePlayer.currentQuestlog[quest.Id] ~= quest then
        QuestiePolygon.RemoveObjective(quest.Id, canonicalIndex)
        return nil, {}
    end

    local questEntries = entries[quest.Id]
    if not questEntries then
        questEntries = {}
        entries[quest.Id] = questEntries
    end
    local entry = questEntries[canonicalIndex]
    if not entry then
        entry = {active = true, markers = {}, revision = 0, generation = 0}
        questEntries[canonicalIndex] = entry
    end
    entry.revision = entry.revision + 1
    entry.quest, entry.objective = quest, objective
    local revision = entry.revision
    local function isCancelled()
        return not entry.active or entry.revision ~= revision or not QuestiePolygon.IsEnabled()
            or objective.Completed or QuestiePlayer.currentQuestlog[quest.Id] ~= quest
    end

    -- Collect the full eligible source set before comparing geometry signatures.
    local points, signatureParts, pointsByKey = {}, {}, {}
    local collectedSpawnCount = 0
    for targetKey, spawnData in pairs(objective.spawnList or {}) do
        for areaId, spawns in pairs(spawnData.Spawns or {}) do
            for _, spawn in ipairs(spawns) do
                if Phasing.IsSpawnVisible(spawn[3]) then
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
                                }
                                points[#points + 1] = point
                                signatureParts[#signatureParts + 1] = key
                                pointsByKey[key] = point
                            end
                        end
                    end
                end
                collectedSpawnCount = collectedSpawnCount + 1
                if collectedSpawnCount >= 200 then
                    collectedSpawnCount = 0
                    coroutine.yield()
                    if isCancelled() then return nil, {} end
                end
            end
        end
    end
    if isCancelled() then return nil, {} end
    table.sort(signatureParts)
    local signature = table.concat(signatureParts, "|")

    -- Progress-only updates refresh marker metadata while retaining geometry and route ownership.
    if entry.signature == signature then
        for _, marker in ipairs(entry.markers) do
            local frame = marker.frame
            local data = frame.data
            if data then
                data.QuestData, data.ObjectiveData = quest, objective
                local point = marker.cluster and pointsByKey[marker.cluster.representative.key]
                if point then
                    local spawnData = point.spawnData
                    data.Name, data.ObjectiveTargetId = spawnData.Name, spawnData.Id
                    data.Icon, data.IconColor = spawnData.Icon or objective.Icon, quest.Color
                    data.GetIconScale, data.IconScale = spawnData.GetIconScale, spawnData.GetIconScale()
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
        end
        QuestiePolygon.ScheduleRefresh()
        QuestiePolygon.ScheduleNudging()
        return nil, {}, {entry = entry, generation = entry.generation}
    end

    -- Hide outlines until replacement geometry and markers are ready. Bumping the generation
    -- invalidates earlier waypoint work before its marker frames can be recycled.
    entry.signature, entry.hovered, entry.building = nil, nil, true
    entry.generation = entry.generation + 1
    local waypointWork = {entry = entry, generation = entry.generation}
    _ReleaseMarkers(entry)
    QuestiePolygon.ScheduleRefresh()
    local clusters = PolygonGeometry.Build(points, nil, isCancelled)
    if not clusters or isCancelled() then return nil, {} end

    -- Lazily retain one provider, renderer, layout, and size-change hook across resets.
    if not provider then
        provider = CreateFromMixins(MapCanvasDataProviderMixin, Provider)
        local scrollContainer = WorldMapFrame.ScrollContainer
        local hoverInput
        if type(GetMouseFoci) == "function" and scrollContainer and type(scrollContainer.GetNormalizedCursorPosition) == "function" then
            hoverInput = {getMouseFoci = GetMouseFoci, getCursorPosition = function()
                return scrollContainer:GetNormalizedCursorPosition()
            end}
        end
        renderer = PolygonRenderer.New(WorldMapFrame:GetCanvas(), hoverInput)
        nudging = PolygonNudging.New()
        -- Preference setters resize before writing their new value. Read configured
        -- widths on the next frame; this single retained hook is inert while detached.
        hooksecurefunc(QuestieMap, "RescaleIcons", QuestiePolygon.ScheduleNudging)
    end
    if not provider.owningMap then WorldMapFrame:AddDataProvider(provider) end
    -- Allocate markers with generation ownership before publishing this batch for hover or pinning.
    local icon, iconPerZone = nil, {}
    for clusterIndex, cluster in ipairs(clusters) do
        local point = pointsByKey[cluster.representative.key]
        local spawnData = point.spawnData
        local data = {
            Id = quest.Id, ObjectiveIndex = canonicalIndex, QuestData = quest, ObjectiveData = objective,
            Icon = spawnData.Icon or objective.Icon, IconColor = quest.Color, Name = spawnData.Name,
            Type = objective.Type, ObjectiveTargetId = spawnData.Id,
            GetIconScale = spawnData.GetIconScale, IconScale = spawnData.GetIconScale(),
        }
        local frame = QuestieMap:DrawWorldIcon(data, point.areaId, cluster.x, cluster.y, nil, nil, "map")
        if frame then
            local marker = {frame = frame, entry = entry, cluster = cluster}
            frame.polygonMarker = marker
            entry.markers[#entry.markers + 1] = marker
            icon = {data = data, AlreadySpawnedId = point.targetKey}
            iconPerZone[point.areaId] = {frame, cluster.x, cluster.y}
        end
        if clusterIndex % 30 == 0 then
            coroutine.yield()
            if isCancelled() then return nil, {} end
        end
    end
    entry.building = nil
    entry.signature = signature
    QuestiePolygon.ScheduleNudging()
    QuestiePolygon.ScheduleRefresh()
    return icon, iconPerZone, waypointWork
end
