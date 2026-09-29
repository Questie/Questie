---@class GamepadMapHover
local GamepadMapHover = QuestieLoader:CreateModule("GamepadMapHover")
local _GamepadMapHover = GamepadMapHover.private

---@type MapIconTooltip
local MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
---@type QuestieFrame
local QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")

-- Blizzard's gamepad cursor can't see Questie pins (see HBDHooks), so we find the hovered icon ourselves.

local PIN_TEMPLATE = "HereBeDragonsPinsTemplateQuestie"
local UPDATE_INTERVAL = 0.05
local MAX_DISTANCE_SQUARED = 12 * 12 -- same range as Blizzard's gamepad cursor

local elapsedSinceUpdate = 0
---@type IconFrame?
local hoveredIcon
---@type IconData? Icons are pooled and can get other data while hovered
local hoveredData

function GamepadMapHover.Initialize()
    -- Showing the tooltip on GameTooltip from here taints the gamepad UI
    _GamepadMapHover.tooltip = CreateFrame("GameTooltip", "QuestieGamepadMapTooltip", UIParent, "GameTooltipTemplate")
    _GamepadMapHover.updateFrame = CreateFrame("Frame")
    _GamepadMapHover.updateFrame:SetScript("OnUpdate", _GamepadMapHover.OnUpdate)
end

---@return IconFrame?
function GamepadMapHover.GetHoveredIcon()
    return hoveredIcon
end

function _GamepadMapHover.OnUpdate(_, elapsed)
    elapsedSinceUpdate = elapsedSinceUpdate + elapsed
    if elapsedSinceUpdate < UPDATE_INTERVAL then
        return
    end
    elapsedSinceUpdate = 0
    _GamepadMapHover.Update()
end

function _GamepadMapHover.Update()
    local icon
    if _GamepadMapHover.IsActive() then
        icon = _GamepadMapHover.FindIconUnderCursor()
    end

    if icon ~= hoveredIcon or (icon and icon.data ~= hoveredData) then
        _GamepadMapHover.Leave()
        if icon then
            _GamepadMapHover.Enter(icon)
        end
    end
end

---@return boolean
function _GamepadMapHover.IsActive()
    -- GamepadDisableTooltips is toggled with the right stick
    return WorldMapFrame:IsShown() and InputUtil and InputUtil.IsGamepadUIEnabled() and not GetCVarBool("GamepadDisableTooltips")
end

---@param icon IconFrame?
---@return boolean
local function _IsIconVisible(icon)
    return icon ~= nil and icon.data ~= nil and icon:IsVisible() and (not icon.hidden)
        and select(4, icon.texture:GetVertexColor()) > 0
end

---@return IconFrame?
function _GamepadMapHover.FindIconUnderCursor()
    -- The cursor position is 0, 0 while the soft cursor is hidden
    if not SoftCursor:IsShown() then
        return nil
    end
    local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetGamepadCursorPosition()

    local closestIcon, closestDistance
    for pin in WorldMapFrame:EnumeratePinsByTemplate(PIN_TEMPLATE) do
        local icon = pin.icon
        if _IsIconVisible(icon) then
            -- pin.GetCenter is overridden by HBDHooks
            local pinX, pinY = getmetatable(pin).__index.GetCenter(pin)
            if pinX then
                local dx, dy = pinX - cursorX, pinY - cursorY
                local distance = dx * dx + dy * dy
                if distance <= MAX_DISTANCE_SQUARED and ((not closestDistance) or distance < closestDistance) then
                    closestIcon, closestDistance = icon, distance
                end
            end
        end
    end
    return closestIcon
end

---@param icon IconFrame
function _GamepadMapHover.Enter(icon)
    hoveredIcon = icon
    hoveredData = icon.data
    local tooltip = _GamepadMapHover.tooltip
    MapIconTooltip.ShowOnTooltip(icon, tooltip)
    if tooltip:IsShown() then
        -- There is no mouse cursor to anchor to in gamepad mode
        tooltip:SetAnchorType("ANCHOR_RIGHT")
        tooltip:Show()
    end
end

function _GamepadMapHover.Leave()
    if not hoveredIcon then
        return
    end
    if hoveredData then
        QuestieFrame.ResetHoverHighlights({data = hoveredData})
    end
    _GamepadMapHover.tooltip:Hide()
    hoveredIcon = nil
    hoveredData = nil
end
