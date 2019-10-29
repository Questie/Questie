---@class QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:CreateModule("QuestieOptionsUtils");

function QuestieOptionsUtils:Spacer(o, height)
    return {
        type = "description",
        order = o,
        name = " ",
        fontSize = "large",
        fontHeight = height
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
        Questie:Debug(DEBUG_DEVELOP, message)
    end, time)
end