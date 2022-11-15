---@class WaypointAnimationHelper
local WaypointAnimationHelper = QuestieLoader:CreateModule("WaypointAnimationHelper")

---@type Tween
local Tween = QuestieLoader("Tween")
---@type PinTemplates
local PinTemplates = QuestieLoader("PinTemplates")

local _animations = {}

---comment
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

---comment
---@param baseLine WaypointMapIconFrame|WaypointPinMixin
---@param scale number
---@param duration number @The ticker runs ever 0.01 second so the duration should be a multiple of 0.01
function WaypointAnimationHelper.ScaleWaypointsById(baseLine, scale, duration)
    local canvasScale = baseLine:GetMap():GetCanvasScale()
    for line in baseLine:GetMap():EnumeratePinsByTemplate(PinTemplates.WaypointPinTemplate) do
        if baseLine.data.id == line.data.id then
            WaypointAnimationHelper.ScaleTo(line, canvasScale * scale, duration)
        end
    end
end
