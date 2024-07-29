---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")

local _IsBindTrue

function AutoQuesting.HandleGossipShow()
    if (not Questie.db.profile.autoaccept) or _IsBindTrue(Questie.db.profile.autoModifier) then
        return
    end

    local availableQuests = { QuestieCompat.GetAvailableQuests() }

    if #availableQuests > 0 then
        QuestieCompat.SelectAvailableQuest(1)
    end
end

local bindTruthTable = {
    ['shift'] = function()
        return IsShiftKeyDown()
    end,
    ['ctrl'] = function()
        return IsControlKeyDown()
    end,
    ['alt'] = function()
        return IsAltKeyDown()
    end,
    ['disabled'] = function() return false; end,
}

_IsBindTrue = function(bind)
    return bind and bindTruthTable[bind]()
end

return AutoQuesting
