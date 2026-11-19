---@class QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:CreateModule("QuestieOptionsUtils");

---Keeps settings art from shimmering between texels while a window is dragged at a modified UI scale.
---@param texture Texture?
function QuestieOptionsUtils.DisableSnapping(texture)
    if texture and texture.SetSnapToPixelGrid then
        texture:SetSnapToPixelGrid(false)
        texture:SetTexelSnappingBias(0)
    end
end

---Hides the tooltip of a frame when the frame is hidden. OnLeave alone leaves it showing when the settings close under the mouse.
---@param frame Frame
function QuestieOptionsUtils.HideTooltipOnHide(frame)
    frame:HookScript("OnHide", function(self)
        if GameTooltip:IsOwned(self) then
            GameTooltip:Hide()
        end
    end)
end

local _optionsTimer = nil;
function QuestieOptionsUtils:Delay(time, func, message)
    if(_optionsTimer) then
        Questie:CancelTimer(_optionsTimer)
        _optionsTimer = nil;
    end
    _optionsTimer = Questie:ScheduleTimer(function()
        func()
        Questie.Debug(Questie.DEBUG_DEVELOP, message)
    end, time)
end
