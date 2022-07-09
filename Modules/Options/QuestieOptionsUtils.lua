---@class QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:CreateModule("QuestieOptionsUtils");

--- Creates a vertical spacer with the given height
---@param o number
---@param hidden boolean|nil
function QuestieOptionsUtils:Spacer(o, hidden)
    return {
        type = "description",
        order = o,
        hidden = hidden,
        name = " ",
        fontSize = "large"
    }
end

--- Creates a horizonal spacer with the given width.
---@param o number
---@param width number
function QuestieOptionsUtils:HorizontalSpacer(o, width)
    if not width then
        width = 0.5
    end
    return {
        type = "description",
        order = o,
        name = " ",
        width = width
    }
end

local _optionsTimer = nil;
function QuestieOptionsUtils:Delay(time, func, message)
    if(_optionsTimer) then
        Questie:CancelTimer(_optionsTimer)
        _optionsTimer = nil;
    end
    _optionsTimer = Questie:ScheduleTimer(function()
        func()
        Questie:Debug(Questie.DEBUG_DEVELOP, message)
    end, time)
end