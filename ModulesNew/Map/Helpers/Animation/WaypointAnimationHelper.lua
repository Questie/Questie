---@class WaypointAnimationHelper
local WaypointAnimationHelper = QuestieLoader:CreateModule("WaypointAnimationHelper")

---@type Tween
local Tween = QuestieLoader("Tween")
---@type PinTemplates
local PinTemplates = QuestieLoader("PinTemplates")

-- Up Values
local type = type
local C_Timer = C_Timer

local _animations = {}

--- Scale a single waypoint line
---@param line WaypointMapIconFrame|WaypointPinMixin
---@param scale number
---@param duration number @The ticker runs ever 0.01 second so the duration should be a multiple of 0.01
function WaypointAnimationHelper.ScaleTo(line, scale, duration)
    if type(line) ~= "table" or not line.lineTexture or not line.lineTexture.redraw then
        error("WaypointAnimationHelper.ScaleTo: pin must have a lineTexture and redraw function")
        return
    end
    if type(scale) ~= "number" then
        error("WaypointAnimationHelper.ScaleTo: scale must be a number")
        return
    end
    if type(duration) ~= "number" and duration > 0 then
        error("WaypointAnimationHelper.ScaleTo: duration must be a number")
        return
    end

    if _animations[line] == nil then
        _animations[line] = {}
        _animations[line].animationScale = line.lineTexture.thickness
    end
    _animations[line].animation = Tween.new(duration, _animations[line], { animationScale = scale }, Tween.easing.linear)

    if _animations[line].animationTimer then
        _animations[line].animationTimer:Cancel()
        _animations[line].animationTimer = nil
    end
    _animations[line].animationTimer = C_Timer.NewTicker(0.01, function()
        local complete = _animations[line].animation:update(0.01)
        if line.lineTexture then
            line.lineTexture:redraw(_animations[line].animationScale)
        end
        if complete then
            _animations[line].animationTimer:Cancel()
            _animations[line].animationTimer = nil
        end
    end)
end

---Scale all waypoints on a map that are related to the baseLine object
---@param baseLine WaypointPinMixin
---@param scale number
---@param duration number @The ticker runs ever 0.01 second so the duration should be a multiple of 0.01
function WaypointAnimationHelper.ScaleWaypointsByPin(baseLine, scale, duration)
    local canvasScale = baseLine:GetMap():GetCanvasScale()
    local baseLineType = type(baseLine.data.id)
    ---@param line WaypointMapIconFrame
    for line in baseLine:GetMap():EnumeratePinsByTemplate(PinTemplates.WaypointPinTemplate) do
        if baseLineType == "number" then
            -- This is a regular line frame which only has data for one thing at a time.
            if baseLine.data.id == line.data.id and baseLine.data.type == line.data.type then
                WaypointAnimationHelper.ScaleTo(line, canvasScale * scale, duration)
            end
        elseif baseLineType == "table" then
            -- This is a relation pin, it can have multiple Ids under itself, so we loop them
            for index = 1, #baseLine.data.id do
                if baseLine.data.id[index] == line.data.id and baseLine.data.type[index] == line.data.type then
                    WaypointAnimationHelper.ScaleTo(line, canvasScale * scale, 0.03)
                end
            end
        end
    end
end
