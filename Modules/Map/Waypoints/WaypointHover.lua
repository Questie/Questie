---@class WaypointHover
local WaypointHover = QuestieLoader:CreateModule("WaypointHover")

---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type MapIconTooltip
local MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
---@type QuestieFrame
local QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")

-- One patrol path is hovered at a time, on the world map or the minimap. Hovering a path is
-- hovering its NPC: the NPC's tooltip opens, which highlights all of the NPC's paths.
-- - World map: the NPC's icon opens its own tooltip, as when the icon itself is hovered. An icon
--   that isn't visible can't anchor it; then only the paths highlight.
-- - Minimap: the NPC's tooltip opens on a tooltip of its own, owned by the minimap. Forever's
--   minimap takes GameTooltip every frame while the cursor is over it, for its blip tooltips
--   (Minimap_OnUpdate in Blizzard_Minimap/Mainline/Minimap.lua). And HereBeDragons hides minimap
--   icons out of range, and distance fades them out, while a long patrol's path can still pass
--   close by.

---@alias WaypointHoverSurface "map"|"minimap"

---@type WaypointPath?
local hovered
---@type WaypointHoverSurface?
local hoveredOn
---@type IconFrame? Icon whose tooltip the hovered path opened.
local enteredIcon
---@type GameTooltip?
local minimapTooltip

---@return GameTooltip
local function _MinimapTooltip()
    minimapTooltip = minimapTooltip or CreateFrame("GameTooltip", "QuestieWaypointMinimapTooltip", UIParent, "GameTooltipTemplate")
    return minimapTooltip
end

---Opens the hovered path's tooltip on its map, or only highlights its paths.
---@param path WaypointPath
---@param icon IconFrame?
local function _Enter(path, icon)
    local ownIcon = icon and icon.data == path.data
    if ownIcon and hoveredOn == "minimap" then
        enteredIcon = icon
        -- The highlight is the hover's own, whether or not the tooltip shows.
        QuestieWaypoints.SetHighlighted(path.data, true)
        -- The tooltip lists each of the NPC's quests, however far away and faded their icons are.
        MapIconTooltip.ShowOnTooltip(icon, _MinimapTooltip(), Minimap, QuestieWaypoints.MinimapIcons(path))
        return
    end
    local onEnter = ownIcon and icon:IsVisible() and icon:GetScript("OnEnter")
    if onEnter then
        enteredIcon = icon
        onEnter(icon)
    else
        QuestieWaypoints.SetHighlighted(path.data, true)
    end
end

-- The tooltip highlights the NPC's paths and tints its icons; this resets both. The data is the
-- path's own, since an icon unloaded while hovered may show something else by now.
---@param path WaypointPath
local function _ResetTooltipChanges(path)
    QuestieFrame.ResetHoverHighlights({data = path.data})
end

---Closes the hovered path's tooltip, or leaves it to whoever took it over, and ends its highlight.
---@param path WaypointPath
---@param on WaypointHoverSurface The map the path was hovered on.
local function _Leave(path, on)
    local icon = enteredIcon
    enteredIcon = nil
    if not icon then
        QuestieWaypoints.SetHighlighted(path.data, false)
        return
    end
    if on == "minimap" then
        _MinimapTooltip():Hide()
        _ResetTooltipChanges(path)
        return
    end
    -- Moving onto the icon itself hands the hover over to it.
    if QuestieCompat.GetMouseFocus() == icon then return end
    if GameTooltip:GetOwner() ~= icon then
        -- Another frame took the tooltip; a Questie icon would have ended this hover first. Its
        -- tooltip stays, but nothing of the NPC's may: a modifier key would rebuild it.
        _ResetTooltipChanges(path)
        GameTooltip._Rebuild, GameTooltip.ShownAsMapIcon = nil, false
        return
    end
    local onLeave = icon.data == path.data and icon:GetScript("OnLeave")
    if onLeave then
        onLeave(icon)
    else
        GameTooltip:Hide()
        _ResetTooltipChanges(path)
    end
end

---Sets the path the cursor is over on one map; nil when it is over none there. A map only ends
---its own hover, so the other map's hover is kept.
---@param on WaypointHoverSurface
---@param path WaypointPath?
---@param icon IconFrame? The path's NPC on that map: the world map icon, or its minimap twin.
function WaypointHover.Set(on, path, icon)
    if path == hovered or (not path and hoveredOn ~= on) then return end
    -- Another patrol of the same NPC on the same map keeps its tooltip and highlight.
    if path and hovered and on == hoveredOn and path.data == hovered.data then
        hovered = path
        return
    end
    local previous, previousOn = hovered, hoveredOn
    hovered, hoveredOn = path, path and on or nil
    if previous then _Leave(previous, previousOn) end
    if path then _Enter(path, icon) end
end

---Ends a path hover before an icon's tooltip opens, so the path's tooltip changes are undone first.
---Called from the icon tooltip. On the world map, the icon the hover opened keeps its tooltip; on
---the minimap, the icon's tooltip replaces the path's.
---@param icon IconFrame
function WaypointHover.End(icon)
    if hovered and (icon ~= enteredIcon or hoveredOn == "minimap") then WaypointHover.Set(hoveredOn, nil) end
end

-- Hover reach

---How far from a line, in the units its width is in, hovering reaches: one unit past its edge, tuned in
---game on the world map.
---@return number
function WaypointHover.Radius()
    return Questie.db.profile.waypointWidth / 2 + 1
end
