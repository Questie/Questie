---@class PolygonNudging
local PolygonNudging = QuestieLoader:CreateModule("PolygonNudging")

---@class PolygonNudgeItem
---@field key string Stable quest/objective/map/location identity, never a pooled frame name.
---@field uiMapId number Original UI map; projections never combine different map coordinates.
---@field x number Original zone percentage, not a screen position.
---@field y number Original zone percentage.
---@field width number Base configured icon width in HBD wrapper units, without map-type scaling or tracker animation.
---@field share string? Items in one group with the same share look identical and take one slot, overlapping exactly.

local MAP_TOLERANCE = 0.01 -- Percentage points; normalized equivalent is 0.0001.
local SPACING_FACTOR = 0.7 -- Slight overlap keeps related markers visually connected.
---@class PolygonNudgeLayout
local Layout = {}
Layout.__index = Layout

local function _IsFinite(value)
    return not (issecretvalue and issecretvalue(value)) and type(value) == "number"
        and value > -math.huge and value < math.huge
end

---Groups almost-identical original locations and assigns stable horizontal slots.
---Only membership, coordinates, or configured widths affect this result. Zoom, viewport,
---neighboring hitboxes, and visibility are intentionally not layout inputs.
---@param items PolygonNudgeItem[]
---@return table<string, number> offsets Horizontal displacement in HBD wrapper units.
function PolygonNudging.Calculate(items)
    -- Stable identities determine both the group seeds and the left-to-right order.
    local orderedItems = {}
    for _, item in ipairs(items) do
        if type(item.key) == "string" and _IsFinite(item.uiMapId) and _IsFinite(item.x) and _IsFinite(item.y)
            and item.x >= 0 and item.x <= 100 and item.y >= 0 and item.y <= 100
            and _IsFinite(item.width) and item.width > 0 and (item.share == nil or type(item.share) == "string") then
            orderedItems[#orderedItems + 1] = item
        end
    end
    table.sort(orderedItems, function(a, b) return a.key < b.key end)

    -- The first stable identity is the seed. Comparing only with seeds prevents
    -- near-location chains from gradually collecting otherwise unrelated markers.
    local groups = {}
    for _, item in ipairs(orderedItems) do
        local group
        for _, candidate in ipairs(groups) do
            local seed = candidate.items[1]
            if item.uiMapId == seed.uiMapId and math.abs(item.x - seed.x) <= MAP_TOLERANCE
                and math.abs(item.y - seed.y) <= MAP_TOLERANCE then
                local dx, dy = item.x - seed.x, item.y - seed.y
                if dx * dx + dy * dy <= MAP_TOLERANCE^2 + 1e-12 then
                    group = candidate
                    break
                end
            end
        end
        if not group then
            group = {items = {}, widestIconWidth = 0}
            groups[#groups + 1] = group
        end
        group.items[#group.items + 1] = item
        group.widestIconWidth = math.max(group.widestIconWidth, item.width)
    end

    -- Center each stack on its original location, using the widest configured icon. Identical
    -- items share a slot: overlapping them hides nothing, while separate slots would suggest
    -- markers that differ.
    local offsets = {}
    for _, group in ipairs(groups) do
        local slots, slotOf, itemSlots = 0, {}, {}
        for index, item in ipairs(group.items) do
            local slot = item.share and slotOf[item.share]
            if not slot then
                slots = slots + 1
                slot = slots
                if item.share then slotOf[item.share] = slot end
            end
            itemSlots[index] = slot
        end
        local spacing = group.widestIconWidth * SPACING_FACTOR
        local centerSlot = (slots + 1) / 2
        for index, item in ipairs(group.items) do
            offsets[item.key] = (itemSlots[index] - centerSlot) * spacing
        end
    end
    return offsets
end

---Owns child-icon anchors and the optional HBD reanchoring callback, not geographic positions.
---@return PolygonNudgeLayout
function PolygonNudging.New()
    local layout = setmetatable({owned = {}, offsets = {}, enabled = true}, Layout)
    layout.onPinUpdated = function(frame, pin) layout:Apply(frame, pin) end
    return layout
end

---Replaces marker membership and reapplies offsets; unchanged signatures skip regrouping.
---Callers include hidden/offscreen/queued members so visibility alone cannot change slots.
---Configured width never reads the icon's zoomed or animated native dimensions.
---@param markers PolygonMarker[]
---@param iconScale number Questie's configured world-map icon scale.
function Layout:Update(markers, iconScale)
    -- Gather original locations and configured widths, not current screen bounds.
    local items, currentOwnership, signatureParts = {}, {}, {}
    for _, marker in ipairs(markers) do
        local frame = marker.frame
        local data = frame.data
        -- Preference setters rescale before writing the new setting. The deferred
        -- refresh reads the current getter, not IconScale cached during that rescale.
        local configuredScale = type(data.GetIconScale) == "function" and data:GetIconScale() or nil
        if not _IsFinite(configuredScale) or configuredScale <= 0 then configuredScale = data.IconScale end
        if not _IsFinite(configuredScale) or configuredScale <= 0 then configuredScale = 1 end
        local width = 16 * configuredScale * iconScale
        if _IsFinite(width) and width > 0 and _IsFinite(frame.UiMapID) and _IsFinite(frame.x) and _IsFinite(frame.y)
            and frame.x >= 0 and frame.x <= 100 and frame.y >= 0 and frame.y <= 100 then
            local key = string.format("%010d:%04d:%06d:%.12f:%.12f", marker.entry.quest.Id,
                data.ObjectiveIndex, frame.UiMapID, frame.x, frame.y)
            -- A marker with an area needs its own slot for hovering and clicking. Markers without
            -- one, of the same quest and icon, look identical and may overlap.
            local cluster = marker.cluster
            local share
            if not (cluster and cluster.outline) then
                share = string.format("%d:%s", marker.entry.quest.Id, tostring(data.Icon))
            end
            items[#items + 1] = {key = key, uiMapId = frame.UiMapID, x = frame.x, y = frame.y, width = width, share = share}
            currentOwnership[frame] = {marker = marker, key = key}
            signatureParts[#signatureParts + 1] = table.concat({key, width, share or ""}, ":")
        end
    end

    -- Regroup only when identity, original coordinates, or configured size changes.
    table.sort(signatureParts)
    local nextSignature = table.concat(signatureParts, "|")
    if self.signature ~= nextSignature then
        self.offsets = PolygonNudging.Calculate(items)
        self.signature = nextSignature
    end
    -- Remove stale ownership before installing callbacks on current pooled frames.
    for frame, state in pairs(self.owned) do
        if not currentOwnership[frame] or currentOwnership[frame].marker ~= state.marker then
            self:Remove(frame)
        end
    end
    self.owned = currentOwnership
    for frame, state in pairs(currentOwnership) do
        state.offset = self.offsets[state.key]
        frame.OnWorldMapPinUpdated = self.onPinUpdated
        self:Apply(frame)
    end
end

---Reapplies a stored slot after HBD acquisition or zoom, without regrouping.
---@param frame IconFrame Child icon; its original map coordinates remain unchanged.
---@param pin Frame? HBD wrapper from the callback; otherwise use the icon's current parent.
function Layout:Apply(frame, pin)
    local state = self.owned[frame]
    if not state or frame.polygonMarker ~= state.marker then return end
    local parent = pin or frame:GetParent()
    if not parent or parent ~= frame:GetParent() or parent.pinTemplate ~= "HereBeDragonsPinsTemplateQuestie"
        or parent.icon ~= frame then return end

    -- Keep spacing in wrapper units so HBD's zoom sizing scales icons and separation together.
    -- Convert to child anchor units; UI scale is already inherited by the wrapper.
    -- Only the child moves, leaving the geographic anchor and configured slots unchanged.
    local offsetX = 0
    if self.enabled then
        local parentEffectiveScale = parent:GetEffectiveScale()
        local iconEffectiveScale = frame:GetEffectiveScale()
        if not _IsFinite(parentEffectiveScale) or parentEffectiveScale <= 0
            or not _IsFinite(iconEffectiveScale) or iconEffectiveScale <= 0 then return end
        offsetX = state.offset * parentEffectiveScale / iconEffectiveScale
        if not _IsFinite(offsetX) then return end
    end
    local point, relative, relativePoint, oldX, oldY = frame:GetPoint()
    if point ~= "CENTER" or relative ~= parent or relativePoint ~= "CENTER" or oldX ~= offsetX or oldY ~= 0 then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", parent, "CENTER", offsetX, 0)
    end
end

function Layout:Reapply()
    for frame in pairs(self.owned) do self:Apply(frame) end
end

-- Disabling recenters child anchors but retains membership and cached slots for the next show.
function Layout:SetEnabled(enabled)
    self.enabled = enabled
    self:Reapply()
end

---Releases this layout's callback and recenters only an icon still owned by the same marker.
---@param frame IconFrame
function Layout:Remove(frame)
    local state = self.owned[frame]
    if not state then return end
    if frame.OnWorldMapPinUpdated == self.onPinUpdated then frame.OnWorldMapPinUpdated = nil end
    if frame.polygonMarker == state.marker then
        local parent = frame:GetParent()
        if parent and parent.pinTemplate == "HereBeDragonsPinsTemplateQuestie" and parent.icon == frame then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
        end
    end
    self.owned[frame] = nil
end

function Layout:Clear()
    for frame in pairs(self.owned) do self:Remove(frame) end
    self.signature, self.offsets = nil, {}
end
