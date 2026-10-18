-- luacheck: read globals issecretvalue
---Hover for what Questie draws on the world map's canvas beneath its icons: quest areas and patrol
---paths. Each drawing feature adds a layer and keeps its own drawing. One poller reads the cursor
---while the map is open and offers it to the layers top down: a layer drawn above another wins the
---cursor over it, as everything with mouse focus above the map, such as Questie's icons, Blizzard's
---pins and other UI, wins over every layer. Nothing here takes mouse input or calls protected API.
---@class WorldMapLayers
local WorldMapLayers = QuestieLoader:CreateModule("WorldMapLayers")

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@alias WorldMapLayerName "areas"|"paths"

---Where the cursor is on the world map's canvas. A fresh table for each offer.
---@class WorldMapCursor
---@field mapId number The shown map. A layer hovers only what it drew for this map.
---@field x number Canvas units right of the canvas's left edge.
---@field y number Canvas units below its top edge.
---@field width number The canvas's size in canvas units: x / width * 100 is map percent.
---@field height number
---@field scale number The canvas's zoom. A reach measured on screen, in map UI units, is that many canvas units divided by scale.

---One kind of drawing on the world map. The stack only orders the layers and hovers them. It offers
---the cursor only while nothing covers the map and the gamepad UI is off; a layer that hovers again
---between offers, such as after drawing anew under the cursor last offered, checks those rules itself.
---@class WorldMapLayer
---@field Hover fun(cursor: WorldMapCursor?): boolean Hovers what lies under the cursor and returns whether anything does; the layers beneath then get nil. nil ends the layer's hover.

-- The layers, bottom to top. Each draws above the ones before it and wins the cursor over them, so
-- draw order and hover order both come from this table. A new drawing feature adds one row.
---@type {name: WorldMapLayerName, FrameLevel: fun(): number}[]
local LAYER_ORDER = {
    -- Blizzard's own level for quest areas: 2004 on Era and 2007 on Forever, where more pin types come first.
    {name = "areas", FrameLevel = function()
        return WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB")
    end},
    -- Below Questie's icons, which draw from 2016 up, or in a block of their own below Blizzard's quest pins
    -- (QuestieMap.utils.SetDrawOrder).
    {name = "paths", FrameLevel = function() return 2015 end},
}

---@class WorldMapLayerState
---@field name WorldMapLayerName
---@field layer WorldMapLayer
---@field offered boolean It had the cursor at the last offer, so it gets nil once when it stops having it.
---@field failed boolean Its Hover threw; it is skipped until its next Invalidate.
---@field reported boolean Its first failure was reported; later ones stay quiet, as it may fail on every redraw.

---@type table<WorldMapLayerName, WorldMapLayerState>
local states = {}
---@type Frame?
local poller
-- The normalized cursor and the zoom at the last offer; nil off the canvas.
local lastX, lastY, lastScale
-- A layer drew anew, or the map opened: offer the cursor again even though it is still.
local dirty = true

---@param value any
---@return boolean
local function _IsFinite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

-- Cursor

---The cursor in canvas units, or nil while nothing drawn may hover.
---@param x number Normalized.
---@param y number
---@param scale number
---@return WorldMapCursor?
local function _Cursor(x, y, scale)
    -- The gamepad cursor is not the mouse's, and GameTooltip from per-frame code taints the gamepad UI.
    if QuestieCompat.IsGamepadUIEnabled() then return nil end
    -- Paths and areas take no mouse input: only the bare map lets them hover.
    if QuestieCompat.GetMouseFocus() ~= WorldMapFrame.ScrollContainer then return nil end
    local canvas = WorldMapFrame:GetCanvas()
    local width, height = canvas:GetWidth(), canvas:GetHeight()
    if not (width > 0 and height > 0) then return nil end
    return {mapId = WorldMapFrame:GetMapID(), x = x * width, y = y * height, width = width, height = height, scale = scale}
end

-- Dispatch

---@param state WorldMapLayerState
---@param cursor WorldMapCursor?
---@return boolean claimed
local function _Hover(state, cursor)
    local ok, hovered = pcall(state.layer.Hover, cursor)
    if ok then return hovered == true end
    if not state.reported then
        state.reported = true
        Questie.Error("World map " .. state.name .. " hover failed:", hovered)
    end
    state.failed, state.offered = true, false
    pcall(state.layer.Hover, nil)
    return false
end

---Offers the cursor top down until a layer claims it; each layer beneath that had it gets nil once.
---@param cursor WorldMapCursor?
local function _Offer(cursor)
    local claimed = false
    for i = #LAYER_ORDER, 1, -1 do
        local state = states[LAYER_ORDER[i].name]
        if state and not state.failed then
            if cursor and not claimed then
                state.offered = true
                claimed = _Hover(state, cursor)
            elseif state.offered then
                state.offered = false
                _Hover(state, nil)
            end
        end
    end
end

-- Poller
-- One frame on the canvas runs while the map is open. It offers the cursor only when it moved, the
-- zoom changed, or a layer drew anew; UI appearing over a still cursor is noticed on its next move.

local function _Poll()
    local x, y, scale
    -- Blizzard clamps the normalized position to the canvas edges, so the canvas itself must be under the cursor.
    if WorldMapFrame:GetCanvas():IsMouseOver() then
        x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        -- Secret values cannot even be compared; a canvas not laid out yet normalizes to NaN or infinity.
        if (issecretvalue and (issecretvalue(x) or issecretvalue(y))) or not (_IsFinite(x) and _IsFinite(y)) then
            x, y = nil, nil
        end
        scale = WorldMapFrame.ScrollContainer:GetCanvasScale()
    end
    if not dirty and x == lastX and y == lastY and scale == lastScale then return end
    dirty, lastX, lastY, lastScale = false, x, y, scale
    _Offer(x and _Cursor(x, y, scale) or nil)
end

---Ends every hover and forgets the cursor, so the next poll offers it afresh.
local function _EndAll()
    _Offer(nil)
    lastX, lastY, lastScale, dirty = nil, nil, nil, true
end

local function _OnUpdate()
    local ok, err = pcall(_Poll)
    if ok then return end
    -- Polling stops until the map opens again; the hovers it started end now.
    Questie.Error("World map hover failed:", err)
    poller:SetScript("OnUpdate", nil)
    pcall(_EndAll)
end

local function _CreatePoller()
    poller = CreateFrame("Frame", nil, WorldMapFrame:GetCanvas())
    poller:SetScript("OnUpdate", _OnUpdate)
    -- Closing the map ends every hover; opening it offers the cursor afresh, also after an error.
    poller:SetScript("OnHide", function() pcall(_EndAll) end)
    poller:SetScript("OnShow", function() poller:SetScript("OnUpdate", _OnUpdate) end)
end

---@param name WorldMapLayerName
---@return {name: WorldMapLayerName, FrameLevel: fun(): number}
local function _Row(name)
    for _, row in ipairs(LAYER_ORDER) do
        if row.name == name then return row end
    end
    error("WorldMapLayers: unknown layer " .. tostring(name))
end

---Adds a feature's layer at its place in the stack; hover starts with the next frame the map is open.
---@param name WorldMapLayerName
---@param layer WorldMapLayer
function WorldMapLayers.AddLayer(name, layer)
    _Row(name)
    states[name] = {name = name, layer = layer, offered = false, failed = false, reported = false}
    dirty = true
    if not poller then _CreatePoller() end
end

---The layer's drawing changed, so what lies under a still cursor may have too: offer the cursor again
---on the next frame. A layer whose Hover failed is offered it again from then on.
---@param name WorldMapLayerName
function WorldMapLayers.Invalidate(name)
    _Row(name)
    local state = states[name]
    if state then state.failed = false end
    dirty = true
end

---The frame level the layer's drawings use, so it draws in the order it hovers.
---@param name WorldMapLayerName
---@return number
function WorldMapLayers.FrameLevel(name)
    return _Row(name).FrameLevel()
end
