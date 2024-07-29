---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")

local _IsBindTrue

local shouldRunAuto = true

function AutoQuesting.OnQuestDetail()
    print("AutoQuesting.OnQuestDetail")
    if (not shouldRunAuto) or (not Questie.db.profile.autoaccept) or _IsBindTrue(Questie.db.profile.autoModifier) then
        return
    end

    AcceptQuest()
end

function AutoQuesting.OnQuestGreetings()
    print("AutoQuesting.OnQuestGreetings")
    if (not shouldRunAuto) or (not Questie.db.profile.autoaccept) or _IsBindTrue(Questie.db.profile.autoModifier) then
        shouldRunAuto = false
        return
    end

    local availableQuestsCount = GetNumAvailableQuests()
    if availableQuestsCount > 0 then
        SelectAvailableQuest(1)
    end
end

function AutoQuesting.OnGossipShow()
    print("AutoQuesting.OnGossipShow")
    if (not Questie.db.profile.autoaccept) or _IsBindTrue(Questie.db.profile.autoModifier) then
        return
    end

    local availableQuests = { QuestieCompat.GetAvailableQuests() }

    if #availableQuests > 0 then
        QuestieCompat.SelectAvailableQuest(1)
    end
end

function AutoQuesting.OnGossipClosed()
    print("AutoQuesting.OnGossipClosed")
end

function AutoQuesting.OnQuestFinished()
    print("AutoQuesting.OnQuestFinished")
end

function AutoQuesting.OnQuestAccepted()
    print("AutoQuesting.OnQuestAccepted")
end

function AutoQuesting.OnQuestProgress()
    print("AutoQuesting.OnQuestProgress")
end

function AutoQuesting.OnQuestAcceptConfirm()
    print("AutoQuesting.OnQuestAcceptConfirm")
end

function AutoQuesting.OnQuestComplete()
    print("AutoQuesting.OnQuestComplete")
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
