---@class IconHighlight
local IconHighlight = QuestieLoader:CreateModule("IconHighlight")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- How hovering shows which map icons belong together. A spotlight lights up a hovered quest's world
-- map icons for as long as any hover of them lasts; QuestieFrame starts and ends it with each icon
-- hover. A mark lights up one icon, such as the marker of a hovered quest area.
-- An icon can be lit for more than one reason at once, such as its quest's spotlight and a mark. Each
-- lit icon keeps its color from before the first light and the lights holding it; the last to end
-- restores that color.

---@class IconTint
---@field data IconData What the icon showed when first tinted.
---@field faded boolean? Whether it was faded then.
---@field color number[] Its color before.
---@field tint number[] The tint's color.
---@field opaque boolean? A tint holding it shows it fully opaque, as its quest's spotlight does.
---@field holders table<table, true> The tints holding it.
---@type table<IconFrame, IconTint>
local iconTints = {}

---@param icon IconFrame
---@param holder table
---@param opaque boolean? Shows the icon fully opaque, as its quest's spotlight does; otherwise its opacity, such as a minimap icon's distance fade, stays its own.
local function _Tint(icon, holder, opaque)
    local entry = iconTints[icon]
    local texture = icon.texture
    -- The pool handed the icon out for other data since: its color is now that data's.
    if entry and entry.data ~= icon.data then entry = nil end
    if not entry then
        -- With objective colors, the plain icon color stands out; without them, blueish.
        local profile = Questie.db.profile
        local plain = profile.questObjectiveColors
        if icon.miniMapIcon then plain = profile.questMinimapObjectiveColors end
        entry = {data = icon.data, faded = icon.faded, color = {texture.r, texture.g, texture.b, texture.a},
            tint = plain and {1, 1, 1} or {0.6, 1, 1}, holders = {}}
        iconTints[icon] = entry
    end
    entry.holders[holder] = true
    entry.opaque = entry.opaque or opaque
    -- Tinting again also puts back a tint a redraw undid meanwhile.
    local tint = entry.tint
    texture:SetVertexColor(tint[1], tint[2], tint[3], entry.opaque and 1 or texture.a)
end

---Ends one tint of the icon; the last restores its color. An icon the pool handed out for other data
---since keeps its own, and a fade or redraw during the tint keeps what it set.
---@param icon IconFrame
---@param holder table
local function _Untint(icon, holder)
    local entry = iconTints[icon]
    if not entry or not entry.holders[holder] then return end
    entry.holders[holder] = nil
    if next(entry.holders) then return end
    iconTints[icon] = nil
    if icon.data ~= entry.data then return end
    local texture, saved, tint = icon.texture, entry.color, entry.tint
    local r, g, b, a = texture.r, texture.g, texture.b, texture.a
    if r == tint[1] and g == tint[2] and b == tint[3] then r, g, b = saved[1], saved[2], saved[3] end
    if entry.opaque and icon.faded == entry.faded then a = saved[4] end
    texture:SetVertexColor(r, g, b, a)
end

-- Spotlight
-- One quest is in the spotlight at a time, for as long as any hover of its icons lasts: hovers of one
-- quest overlap, such as a path's and then its icon's, the gamepad's for a moment after the mouse
-- moves, or a tracker preview of all of an objective's icons.

---@class Spotlight
---@field questId QuestId
---@field hovers table<IconData, true> The data of each hover it lasts for.
---@field icons IconFrame[] The icons it lit.
---@type Spotlight?
local spotlight

local function _EndSpotlight()
    local current = spotlight
    if not current then return end
    spotlight = nil
    for i = #current.icons, 1, -1 do _Untint(current.icons[i], current) end
end

---Lights up the world map icons of the hovered icon's quest until EndSpotlight with the hover's data.
---Available and turn-in icons are left as they are, and so are other hidden or faded-out icons. A
---minimap icon's hover lights nothing.
---@param icon IconFrame The hovered icon.
function IconHighlight.Spotlight(icon)
    local data = icon.data
    if icon.miniMapIcon or not data then return end
    if spotlight and spotlight.questId == data.Id then
        spotlight.hovers[data] = true
        return
    end
    -- Another quest's spotlight, such as from a hover that has not ended yet, ends first.
    _EndSpotlight()
    local current = {questId = data.Id, hovers = {[data] = true}, icons = {}}
    spotlight = current
    for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
        local other = pin.icon
        local otherData = other.data
        if otherData and otherData.Id == data.Id and otherData.Type ~= "available" and otherData.Type ~= "complete"
            and (other == icon or not (other.hidden or other.texture.a == 0)) then
            current.icons[#current.icons + 1] = other
            _Tint(other, current, true)
        end
    end
end

---Ends one hover's spotlight; the quest's last hover ending puts its icons back. A hover that lit
---nothing ends nothing.
---@param data IconData The data the hover started with.
function IconHighlight.EndSpotlight(data)
    if spotlight and spotlight.hovers[data] then
        spotlight.hovers[data] = nil
        if not next(spotlight.hovers) then _EndSpotlight() end
    end
end

-- Marks

---Lights up one icon as its quest's spotlight does, but keeping its opacity, for as long as `holder`
---holds it, such as a quest area's hover lighting the marker it is attached to. Other lights of the
---icon may hold it too. Marking it again puts back a light a redraw undid.
---@param icon IconFrame
---@param holder table Identifies this mark; Unmark with it ends the mark.
function IconHighlight.Mark(icon, holder)
    if icon.data then _Tint(icon, holder) end
end

---@param icon IconFrame
---@param holder table
function IconHighlight.Unmark(icon, holder)
    _Untint(icon, holder)
end
