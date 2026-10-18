---@class IconHighlight
local IconHighlight = QuestieLoader:CreateModule("IconHighlight")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- How hovering shows which map icons belong together. It is the same in every icon style and never
-- changes an icon's color:
--  - A hovered icon grows, on either map. QuestieFrame starts and ends each icon hover here.
--  - On the world map, its quest is in the spotlight while any hover of its objective icons lasts:
--    the quest's objective icons show fully opaque with their glow ring grown, and other quests' dim.
--    Quest givers, turn-ins and notes are a layer of their own, which the spotlight leaves as it is.
--  - A mark grows one icon on its own, such as the marker of a hovered quest area.
-- Only a glow ring the player shows grows; with glows off, the dimming and the size tell it.
-- IconHighlight only decides; QuestieFrame sizes the icon's picture, overlay and ring to match,
-- also as the icon is resized.

local DIM_ALPHA = 0.5 -- Other quests' objective icons' opacity under a spotlight, at most.
local GLOW_GROWTH = 1.5 -- A lit or grown icon's glow ring, relative to its usual size.
local GROWTH = 1.35 -- A grown icon's picture, relative to the icon.

-- Marks
-- An icon can be grown for more than one reason at once, such as a quest area's hover and then its
-- own. The last mark to end shrinks it back.

---@class IconMark
---@field data IconData What the icon showed when first marked.
---@field holders table<table, true> The marks holding it.
---@type table<IconFrame, IconMark>
local marks = {}

-- Spotlight
-- One quest is in the spotlight at a time, for as long as any of its icons is hovered: hovers of one
-- quest overlap, such as the gamepad's for a moment after the mouse moves, or a tracker preview of all
-- of an objective's icons. Hovers are told apart by icon and data, so an icon hovered again with the
-- same data, as a patrol path's hover hands over to its icon, is still one hover.

---@class SpotlitIcon
---@field data IconData What the icon showed when the spotlight reached it.
---@field faded boolean? Whether it was faded then.
---@field alpha number Its opacity before.
---@field shown number The opacity the spotlight gave it.
---@field lit boolean? One of the quest's own: fully opaque, its glow ring grown. Otherwise dimmed.

---@class Spotlight
---@field questId QuestId
---@field hovers table<IconFrame, IconData> Each icon hovered, with the data its hover started with.
---@field icons table<IconFrame, SpotlitIcon> The icons it lit or dimmed.
---@type Spotlight?
local spotlight

---Grows the icon's picture while it is marked and its glow ring while it is marked or lit, and puts
---them back otherwise.
---@param icon IconFrame
local function _UpdateSize(icon)
    local marked = marks[icon] ~= nil
    local spotlit = spotlight and spotlight.icons[icon]
    icon.pictureScale = marked and GROWTH or nil
    icon.glowScale = (marked or (spotlit and spotlit.lit)) and GLOW_GROWTH or nil
    icon:GlowUpdate()
end

---Sets the icon's opacity and its glow ring's with it, as a fade does.
---@param icon IconFrame
---@param alpha number
local function _SetAlpha(icon, alpha)
    local texture, glow = icon.texture, icon.glowTexture
    texture:SetVertexColor(texture.r, texture.g, texture.b, alpha)
    glow:SetVertexColor(glow.r, glow.g, glow.b, alpha)
end

local function _EndSpotlight()
    local current = spotlight
    if not current then return end
    spotlight = nil
    for icon, spotlit in pairs(current.icons) do
        -- An icon the pool handed out since, or one a fade or redraw changed meanwhile, keeps what it has.
        if icon.data == spotlit.data and icon.faded == spotlit.faded and icon.texture.a == spotlit.shown then
            _SetAlpha(icon, spotlit.alpha)
        end
        if spotlit.lit then _UpdateSize(icon) end
    end
end

---Whether the icon takes part in a spotlight: hovering it starts one, and a spotlight lights or dims it.
---Today these are the icons of quest objectives. Quest givers, turn-ins and notes are another layer of
---the map.
---@param data IconData
---@return boolean
local function _InSpotlight(data)
    local iconType = data.Type
    return iconType ~= "available" and iconType ~= "complete" and iconType ~= "manual"
end

---Lights up the world map objective icons of the hovered icon's quest and dims other quests'. Only an
---objective's icon puts its quest in the spotlight, and only objective icons take part: quest givers,
---turn-ins and notes keep their opacity. Hidden icons and those faded out to nothing are left alone. A
---closed world map shows nothing to light.
---@param icon IconFrame
local function _Spotlight(icon)
    local data = icon.data
    if icon.miniMapIcon or not _InSpotlight(data) then return end
    if spotlight and spotlight.questId == data.Id then
        spotlight.hovers[icon] = data
        return
    end
    -- HereBeDragons keeps the last map's icons while the world map is closed.
    local map = HBDPins.worldmapProvider:GetMap()
    if not map:IsShown() then return end
    -- Another quest's spotlight, such as from a hover that has not ended yet, ends first.
    _EndSpotlight()
    local current = {questId = data.Id, hovers = {[icon] = data}, icons = {}}
    spotlight = current
    for pin in map:EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
        local other = pin.icon
        local otherData = other.data
        local alpha = other.texture.a
        if otherData and _InSpotlight(otherData) and (other == icon or not (other.hidden or alpha == 0)) then
            local lit = otherData.Id == data.Id
            local shown = lit and 1 or math.min(alpha, DIM_ALPHA)
            current.icons[other] = {data = otherData, faded = other.faded, alpha = alpha, shown = shown, lit = lit}
            if shown ~= alpha then _SetAlpha(other, shown) end
            if lit then _UpdateSize(other) end
        end
    end
end

---Grows one icon, keeping its opacity, for as long as `holder` holds it, such as a quest area's hover
---growing the marker attached to it. Other marks of the icon may hold it too.
---@param icon IconFrame
---@param holder table Identifies this mark; Unmark with it ends the mark.
function IconHighlight.Mark(icon, holder)
    local data = icon.data
    if not data then return end
    local mark = marks[icon]
    -- The pool handed the icon out for other data since: that icon's marks start afresh.
    if not mark or mark.data ~= data then
        mark = {data = data, holders = {}}
        marks[icon] = mark
    end
    mark.holders[holder] = true
    _UpdateSize(icon)
end

---Ends one mark of the icon; the last shrinks it back.
---@param icon IconFrame
---@param holder table
function IconHighlight.Unmark(icon, holder)
    local mark = marks[icon]
    if not mark or not mark.holders[holder] then return end
    mark.holders[holder] = nil
    if next(mark.holders) then return end
    marks[icon] = nil
    _UpdateSize(icon)
end

---Shows an icon's hover until EndHover with its data: the icon grows, and on the world map its quest
---goes in the spotlight.
---@param icon IconFrame The hovered icon.
function IconHighlight.StartHover(icon)
    local data = icon.data
    if not data then return end
    IconHighlight.Mark(icon, data)
    _Spotlight(icon)
end

---Ends one hover: its icon shrinks back unless something else still grows it, and the quest's last
---hover ending puts the map's icons back.
---@param icon IconFrame The hovered icon. It is pooled, so it may show other data by now.
---@param data IconData The data the hover started with.
function IconHighlight.EndHover(icon, data)
    IconHighlight.Unmark(icon, data)
    if spotlight and spotlight.hovers[icon] == data then
        spotlight.hovers[icon] = nil
        if not next(spotlight.hovers) then _EndSpotlight() end
    end
end

---Lets an unloading icon go at once: the pool may hand it out for other data, which shows ungrown.
---The spotlight leaves an icon showing other data as it is when it ends.
---@param icon IconFrame
function IconHighlight.Forget(icon)
    marks[icon] = nil
    icon.pictureScale, icon.glowScale = nil, nil
    icon:GlowUpdate()
end
