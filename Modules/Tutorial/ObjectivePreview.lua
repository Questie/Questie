---@class ObjectivePreview
---@field startAreas ObjectivePreviewStartAreas Set by the client's generated data file.
local ObjectivePreview = QuestieLoader:CreateModule("ObjectivePreview")

---@type PolygonRenderer
local PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

-- A still world map for the objective style popup, in place of a screenshot: the player's start area, with two
-- of its first quests' objectives drawn and hovered as Questie draws them on the world map.
--  - Questie icons: an icon on each spawn Questie draws there, which keeps them the objective filter distance
--    apart. Hovering one grows it, puts its quest in the spotlight, the other quest's icons dimming, and shows
--    the map icon tooltip for the icons under the cursor.
--  - Questie blobs: areas with a marker each, plus point markers for stray spawns. Hovering an area lights it
--    up, grows its marker and shows the tooltip for it; where areas overlap, for each of them. Hovering a
--    marker grows it, lights up its objective's areas and puts its quest in the spotlight, the other quest's
--    markers and areas dimming; its tooltip also lists the areas beneath it.
-- The map is a shipped image and the objectives are generated data, in startAreas. Nothing inside takes the
-- mouse, so the preview stays one button for the popup to click.

local SIZE = 220 -- The preview's width and height.
ObjectivePreview.SIZE = SIZE
local ICON_SIZE = 16
local GLOW_SIZE = 1.13 -- The glow ring, relative to its icon (QuestieFrame's).
local GROWTH, GLOW_GROWTH = 1.35, 1.5 -- A hovered icon's picture and a lit glow ring (IconHighlight's).
local DIM_ALPHA = 0.5 -- Other quests' icons under a spotlight (IconHighlight's).
local FILL_ALPHA, BORDER_ALPHA = 0.25, 0.75 -- Area opacity at full marker opacity (QuestiePolygon's).

-- The map icon tooltip's look: an objective line is indented (TooltipLayout's) and, in blob mode, starts with
-- its area colour (QuestiePolygon's swatch).
local INDENT = "|TInterface\\Minimap\\UI-bonusobjectiveblob-inside.blp:1:13.5|t"
local AREA_SWATCH = "|TInterface\\Addons\\Questie\\Icons\\blobs\\quest-log-fill-r12-120.png:10:10:0:0:32:32:0:32:0:32:%d:%d:%d|t "
local OBJECTIVE_COLOR = "|cFFEEEEEE"

---@alias ObjectivePreviewStyle "icons"|"blobs"

---The client's art set's start areas, from its generated data file in Modules/Tutorial/Previews, which only the
---art set's TOCs load. ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews generates them.
---@class ObjectivePreviewStartAreas
---@field races table<string, string> Each race's start area, by the race's file name from UnitRace.
---@field areas table<string, fun(): ObjectivePreviewArea> Builds the area's tables only when it is shown.

---@class ObjectivePreviewArea
---@field image string The background: the start area's map, explored.
---@field objectives ObjectivePreviewObjective[]

---@class ObjectivePreviewObjective
---@field questId QuestId
---@field quest string English title, for when QuestieDB has none.
---@field level Level
---@field npc NpcId? What the objective counts: an NPC or an item.
---@field item ItemId?
---@field target string English name of what it counts.
---@field needed number
---@field icon string Questie.icons key.
---@field color number[] RGB of its icons' glow rings and its areas.
---@field icons {x: number, y: number}[] The spawns Questie's icon mode draws, the default objective filter distance
---apart and nearest the quest giver first. In percent of the image, as are the clusters.
---@field clusters {x: number, y: number, outline: {x: number, y: number}[]?}[]

---@class ObjectivePreviewMarker
---@field index number Its place in drawing order.
---@field objective ObjectivePreviewObjective
---@field x number In percent of the preview.
---@field y number
---@field outline table[]? Its area's outline; blob markers with an area only.
---@field picture Texture
---@field glow Texture
---@field area Frame? Its area's view, owned by the preview's renderer.

---@class ObjectivePreviewState
---@field view Button
---@field canvas Frame The preview's clipped drawing surface.
---@field renderer PolygonCanvasRenderer?
---@field markers ObjectivePreviewMarker[] In drawing order: a later marker is on top.
---@field areas Frame[]
---@field lines table<ObjectivePreviewObjective, string[]> Each objective's tooltip lines.
---@field hoverKey string? What the cursor hovered when last looked at.

-- Building the preview

---The player's race's start area, or for a race without one its faction's: Northshire, or Durotar's Valley of
---Trials for the Horde.
---@return ObjectivePreviewArea
local function _StartArea()
    local startAreas = ObjectivePreview.startAreas
    local _, race = UnitRace("player")
    local name = startAreas.races[race] or (UnitFactionGroup("player") == "Horde" and "ValleyOfTrials" or "Northshire")
    return startAreas.areas[name]()
end

---The objective's tooltip lines, with the names in the client's language when QuestieDB has them.
---@param objective ObjectivePreviewObjective
---@param style ObjectivePreviewStyle
---@return string[]
local function _TooltipLines(objective, style)
    local quest = QuestieDB.QueryQuestSingle(objective.questId, "name") or objective.quest
    local target = objective.item and QuestieDB.QueryItemSingle(objective.item, "name")
        or objective.npc and QuestieDB.QueryNPCSingle(objective.npc, "name")
    local swatch = ""
    if style == "blobs" then
        local color = objective.color
        swatch = string.format(AREA_SWATCH, math.floor(color[1] * 255 + 0.5), math.floor(color[2] * 255 + 0.5),
            math.floor(color[3] * 255 + 0.5))
    end
    return {
        QuestieLib:PrintDifficultyColor(objective.level, "[" .. objective.level .. "] " .. quest),
        INDENT .. OBJECTIVE_COLOR .. swatch .. OBJECTIVE_COLOR .. "0/" .. objective.needed .. " " .. (target or objective.target),
    }
end

---@param state ObjectivePreviewState
---@param objective ObjectivePreviewObjective
---@param spot {x: number, y: number, outline: table[]?}
---@return ObjectivePreviewMarker
local function _CreateMarker(state, objective, spot)
    local frame = CreateFrame("Frame", nil, state.canvas)
    frame:SetFrameLevel(state.canvas:GetFrameLevel() + 2)
    frame:SetSize(ICON_SIZE, ICON_SIZE)
    frame:SetPoint("CENTER", state.canvas, "TOPLEFT", spot.x / 100 * SIZE, -spot.y / 100 * SIZE)
    local glow = frame:CreateTexture(nil, "OVERLAY", nil, -1)
    glow:SetPoint("CENTER")
    glow:SetTexture(Questie.icons["glow"])
    local picture = frame:CreateTexture(nil, "OVERLAY", nil, 0)
    picture:SetPoint("CENTER")
    picture:SetTexture(Questie.icons[objective.icon])
    return {index = #state.markers + 1, objective = objective, x = spot.x, y = spot.y, outline = spot.outline,
        picture = picture, glow = glow}
end

-- Hover
-- Like the world map, an icon under the cursor hovers before the areas beneath it.

---Draws every marker and area for what is hovered: the hovered marker, if any, and the markers of the
---hovered areas.
---@param state ObjectivePreviewState
---@param hoveredMarker ObjectivePreviewMarker?
---@param areaMarkers table<ObjectivePreviewMarker, true>
local function _Style(state, hoveredMarker, areaMarkers)
    local spotlight = hoveredMarker and hoveredMarker.objective
    for _, marker in ipairs(state.markers) do
        local objective, color = marker.objective, marker.objective.color
        local alpha = (spotlight and objective ~= spotlight) and DIM_ALPHA or 1
        local grown = marker == hoveredMarker or areaMarkers[marker] == true
        local lit = grown or objective == spotlight
        local pictureSize = ICON_SIZE * (grown and GROWTH or 1)
        local glowSize = ICON_SIZE * GLOW_SIZE * (lit and GLOW_GROWTH or 1)
        marker.picture:SetSize(pictureSize, pictureSize)
        marker.picture:SetVertexColor(1, 1, 1, alpha)
        marker.glow:SetSize(glowSize, glowSize)
        marker.glow:SetVertexColor(color[1], color[2], color[3], alpha)
        if marker.area then
            state.renderer:Style(marker.area, {
                points = marker.outline, marker = marker,
                color = {color[1], color[2], color[3], FILL_ALPHA * alpha},
                borderAlpha = BORDER_ALPHA * alpha,
                highlighted = objective == spotlight,
            }, state.canvas:GetFrameLevel() + 1)
        end
    end
    -- Publishing again combines the highlights just styled with the cursor's.
    if state.renderer then state.renderer:SetVisibleFrames(state.areas) end
end

---Shows the map icon tooltip for the markers' objectives, each once, or hides the preview's own.
---@param state ObjectivePreviewState
---@param markers ObjectivePreviewMarker[]
local function _ShowTooltip(state, markers)
    if #markers == 0 then
        if GameTooltip:IsOwned(state.view) then GameTooltip:Hide() end
        return
    end
    -- Grows up and right from the cursor, as MapIconTooltip's does.
    GameTooltip:SetOwner(state.view, "ANCHOR_CURSOR_RIGHT", 5, 2)
    local listed = {}
    for _, marker in ipairs(markers) do
        local objective = marker.objective
        if not listed[objective] then
            listed[objective] = true
            for _, line in ipairs(state.lines[objective]) do GameTooltip:AddLine(line) end
        end
    end
    GameTooltip:Show()
end

---The point under the cursor, in percent of the preview, or nil while the preview does not have the mouse,
---such as under another frame or in the gamepad UI.
---@param state ObjectivePreviewState
---@return number? x
---@return number? y
local function _Cursor(state)
    if QuestieCompat.IsGamepadUIEnabled() or QuestieCompat.GetMouseFocus() ~= state.view then return end
    local canvas = state.canvas
    local scale = canvas:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    return (cursorX / scale - canvas:GetLeft()) / SIZE * 100, (canvas:GetTop() - cursorY / scale) / SIZE * 100
end

---The markers whose icons are under the point, topmost first; icons take the cursor at their usual size.
---@param state ObjectivePreviewState
---@param x number
---@param y number
---@return ObjectivePreviewMarker[]
local function _MarkersAt(state, x, y)
    local found = {}
    for index = #state.markers, 1, -1 do
        local marker = state.markers[index]
        if math.abs(x - marker.x) * SIZE / 100 <= ICON_SIZE / 2 and math.abs(y - marker.y) * SIZE / 100 <= ICON_SIZE / 2 then
            found[#found + 1] = marker
        end
    end
    return found
end

---Follows the cursor, redrawing only when what it hovers changes. A hovered marker's tooltip also lists the
---icons and areas beneath it, but areas only hover over bare map.
---@param state ObjectivePreviewState
local function _Update(state)
    local x, y = _Cursor(state)
    if not x and state.hoverKey == "" then return end
    local listed = x and _MarkersAt(state, x, y) or {}
    local marker = listed[1]
    local overAreas = x ~= nil and marker == nil

    local areaMarkers = {}
    local key = marker and ("marker" .. marker.index) or ""
    if state.renderer then
        state.renderer:Hover(overAreas and x or nil, overAreas and y or nil)
        for _, shape in ipairs(x and state.renderer:ShapesAt(x, y) or {}) do
            listed[#listed + 1] = shape.marker
            if overAreas then areaMarkers[shape.marker] = true end
            key = key .. ":" .. shape.marker.index
        end
    end
    if key == state.hoverKey then return end
    state.hoverKey = key
    _Style(state, marker, areaMarkers)
    _ShowTooltip(state, listed)
end

---Creates the 220 by 220 preview of the style, for the caller to place. Its own scripts are free for the
---caller: it follows the cursor from a child frame.
---@param parent Frame
---@param style ObjectivePreviewStyle
---@return Button
function ObjectivePreview.Create(parent, style)
    local area = _StartArea()
    local view = CreateFrame("Button", nil, parent)
    view:SetSize(SIZE, SIZE)
    local map = view:CreateTexture(nil, "BACKGROUND")
    map:SetAllPoints()
    map:SetTexture(area.image)
    -- Clipping here rather than on the view leaves the caller's own children, such as a border, unclipped.
    local canvas = CreateFrame("Frame", nil, view)
    canvas:SetAllPoints()
    canvas:SetClipsChildren(true)

    ---@type ObjectivePreviewState
    local state = {view = view, canvas = canvas, markers = {}, areas = {}, lines = {},
        renderer = style == "blobs" and PolygonRenderer.New(canvas, {}) or nil}
    for _, objective in ipairs(area.objectives) do
        state.lines[objective] = _TooltipLines(objective, style)
        for _, spot in ipairs(style == "blobs" and objective.clusters or objective.icons) do
            local marker = _CreateMarker(state, objective, spot)
            state.markers[#state.markers + 1] = marker
            if marker.outline then
                local color = objective.color
                marker.area = state.renderer:Create({points = marker.outline, color = {color[1], color[2], color[3], FILL_ALPHA}},
                    SIZE, SIZE, canvas:GetFrameLevel() + 1)
                state.areas[#state.areas + 1] = marker.area
            end
        end
    end
    _Style(state, nil, {})

    local driver = CreateFrame("Frame", nil, view)
    driver:SetScript("OnUpdate", function() _Update(state) end)
    driver:SetScript("OnHide", function()
        state.hoverKey = nil
        if state.renderer then state.renderer:Hover(nil, nil) end
        _Style(state, nil, {})
        _ShowTooltip(state, {})
    end)
    return view
end
