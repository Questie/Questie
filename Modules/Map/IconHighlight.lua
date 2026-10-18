---@class IconHighlight
local IconHighlight = QuestieLoader:CreateModule("IconHighlight")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- How hovering shows which map icons belong together. It is the same in every icon style and never
-- changes an icon's color:
--  - A hovered icon grows, on either map. QuestieFrame starts and ends each icon hover here.
--  - On the world map, its quest is in the spotlight while any hover of its icons lasts: the quest's
--    icons show fully opaque with their glow ring grown, and all other icons dim.
--  - A mark grows one icon on its own, such as the marker of a hovered quest area.
-- Only a glow ring the player shows grows; with glows off, the dimming and the size tell it.

local DIM_ALPHA = 0.5 -- The other icons' opacity under a spotlight, at most.
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
-- One quest is in the spotlight at a time, for as long as any hover of its icons lasts: hovers of one
-- quest overlap, such as a path's and then its icon's, the gamepad's for a moment after the mouse
-- moves, or a tracker preview of all of an objective's icons.

---@class SpotlitIcon
---@field data IconData What the icon showed when the spotlight reached it.
---@field faded boolean? Whether it was faded then.
---@field alpha number Its opacity before.
---@field shown number The opacity the spotlight gave it.
---@field lit boolean? One of the quest's own: fully opaque, its glow ring grown. Otherwise dimmed.

---@class Spotlight
---@field questId QuestId
---@field hovers table<IconData, true> The data of each hover it lasts for.
---@field icons table<IconFrame, SpotlitIcon> The icons it lit or dimmed.
---@type Spotlight?
local spotlight

---Grows the icon's glow ring while it is lit or marked, and puts it back otherwise. QuestieFrame keeps
---that size for as long as `glowScale` asks, and shows no ring the player turned off.
---@param icon IconFrame
local function _UpdateGlow(icon)
    local spotlit = spotlight and spotlight.icons[icon]
    icon.glowScale = (marks[icon] or (spotlit and spotlit.lit)) and GLOW_GROWTH or nil
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

---Grows the icon's picture around its center, as large as the icon is now. The frame keeps its size,
---so where the cursor finds the icon does not change.
---@param icon IconFrame
local function _Grow(icon)
    local texture = icon.texture
    texture:ClearAllPoints()
    texture:SetPoint("CENTER", icon, "CENTER")
    texture:SetSize(icon:GetWidth() * GROWTH, icon:GetHeight() * GROWTH)
end

---@param icon IconFrame
local function _Shrink(icon)
    local texture = icon.texture
    texture:ClearAllPoints()
    texture:SetAllPoints(icon)
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
        _UpdateGlow(icon)
    end
end

---Lights up the world map icons of the hovered icon's quest and dims all others. Only an objective's
---icon puts its quest in the spotlight: quest givers, turn-ins and notes have nothing of theirs to show.
---The quest's givers and turn-ins stay as they are, and hidden icons or those faded out to nothing are
---left alone.
---@param icon IconFrame
local function _Spotlight(icon)
    local data = icon.data
    if icon.miniMapIcon or data.Type == "available" or data.Type == "complete" or data.Type == "manual" then return end
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
        local alpha = other.texture.a
        if otherData and (other == icon or not (other.hidden or alpha == 0)) then
            local ofQuest = otherData.Id == data.Id
            local lit = ofQuest and otherData.Type ~= "available" and otherData.Type ~= "complete"
            if lit or not ofQuest then
                local shown = lit and 1 or math.min(alpha, DIM_ALPHA)
                current.icons[other] = {data = otherData, faded = other.faded, alpha = alpha, shown = shown, lit = lit}
                if shown ~= alpha then _SetAlpha(other, shown) end
                if lit then _UpdateGlow(other) end
            end
        end
    end
end

---Grows one icon, keeping its opacity, for as long as `holder` holds it, such as a quest area's hover
---growing the marker attached to it. Other marks of the icon may hold it too. Marking it again follows
---a resize meanwhile, such as the map's zoom.
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
    _Grow(icon)
    _UpdateGlow(icon)
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
    _Shrink(icon)
    _UpdateGlow(icon)
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
    if spotlight and spotlight.hovers[data] then
        spotlight.hovers[data] = nil
        if not next(spotlight.hovers) then _EndSpotlight() end
    end
end

---Lets an unloading icon go at once: the pool may hand it out for other data, which shows unlit.
---@param icon IconFrame
function IconHighlight.Forget(icon)
    if spotlight then spotlight.icons[icon] = nil end
    if marks[icon] then
        marks[icon] = nil
        _Shrink(icon)
    end
    icon.glowScale = nil
end
