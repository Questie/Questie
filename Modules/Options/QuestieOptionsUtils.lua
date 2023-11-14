---@class QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:CreateModule("QuestieOptionsUtils");

--- Creates a vertical spacer with the given height
---@param order number
---@param hidden boolean?
---@param fontSize string?
function QuestieOptionsUtils:Spacer(order, hidden, fontSize)
    local name = " "
    if fontSize == "small" or fontSize == "medium" or fontSize == "large" then
        fontSize = fontSize
    elseif fontSize == "minimal" then
        name = "" -- removing the space from name reduces the height further, but still larger than nothing
        fontSize = "small"
    else
        fontSize = "large"
    end
    return {
        type = "description",
        order = order,
        hidden = hidden,
        name = name,
        fontSize = fontSize,
    }
end

--- Creates a horizonal spacer with the given width.
---@param order number
---@param width number?
---@param hidden boolean?
function QuestieOptionsUtils:HorizontalSpacer(order, width, hidden)
    if not width then
        width = 0.5
    end
    return {
        type = "description",
        order = order,
        name = " ",
        width = width,
        hidden = hidden,
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
