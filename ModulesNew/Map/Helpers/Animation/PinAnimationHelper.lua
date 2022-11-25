---@class PinAnimationHelper
local PinAnimationHelper = QuestieLoader:CreateModule("PinAnimationHelper")

---@type Tween
local Tween = QuestieLoader("Tween")

local _animations = {}

---comment
---@param pin MapIconFrame|BasePinMixin
---@param scale number
---@param duration number @The ticker runs ever 0.01 second so the duration should be a multiple of 0.01
function PinAnimationHelper.ScaleTo(pin, scale, duration)
    if type(pin) ~= "table" or not pin.GetScale or not pin.SetScale then
        error("PinAnimationHelper.ScaleTo: pin must have GetScale and SetScale methods")
        return
    end
    if type(scale) ~= "number" then
        error("PinAnimationHelper.ScaleTo: scale must be a number")
        return
    end
    if type(duration) ~= "number" and duration > 0 then
        error("PinAnimationHelper.ScaleTo: duration must be a number")
        return
    end

    if _animations[pin] == nil then
        _animations[pin] = {}
        _animations[pin].animationScale = pin:GetScale()
    end
    _animations[pin].animation = Tween.new(duration, _animations[pin], {animationScale =  scale}, Tween.easing.linear)

    if _animations[pin].animationTimer then
        _animations[pin].animationTimer:Cancel()
        _animations[pin].animationTimer = nil
    end
    _animations[pin].animationTimer = C_Timer.NewTicker(0.01, function()
        local complete = _animations[pin].animation:update(0.01)
        -- for _, texture in pairs(pin.textures) do
        --     texture:SetScale(_animations[pin].animationScale)
        -- end
        if pin.textures then
            for textureIndex = 1, #pin.textures do
                pin.textures[textureIndex]:SetScale(_animations[pin].animationScale)
            end
        end
        pin.highlightTexture:SetScale(_animations[pin].animationScale)
        if complete then
            _animations[pin].animationTimer:Cancel()
            _animations[pin].animationTimer = nil
        end
    end)
end


---comment
---@param pins (MapIconFrame|BasePinMixin)[]
---@param scale number
---@param duration number @The ticker runs ever 0.01 second so the duration should be a multiple of 0.01
function PinAnimationHelper.ScaleGroupTo(pins, scale, duration)
    for _, pin in pairs(pins) do
        PinAnimationHelper.ScaleTo(pin, scale, duration)
    end
end
