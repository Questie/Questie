---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")

local _IsBindTrue, _AllQuestWindowsClosed, _IsAllowedToAcceptFromNPC

local shouldRunAuto = true

-- TODO: Migrate DisallowedIDs.lua to AutoQuesting.lua
AutoQuesting.private.disallowedNPCs = {
    accept = {},
}

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

function AutoQuesting.OnGossipShow(a)
    print("AutoQuesting.OnGossipShow")
    if (not shouldRunAuto) or _IsBindTrue(Questie.db.profile.autoModifier) or (not _IsAllowedToAcceptFromNPC()) then
        shouldRunAuto = false
        return
    end

    local completeQuests = { QuestieCompat.GetActiveQuests() }
    if #completeQuests > 0 then
        QuestieCompat.SelectAvailableQuest(1)
        return
    end

    if (not Questie.db.profile.autoaccept) then
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

    C_Timer.After(0.5, function()
        if _AllQuestWindowsClosed() then
            AutoQuesting.Reset()
        end
    end)
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

function AutoQuesting.Reset()
    shouldRunAuto = true
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

_IsAllowedToAcceptFromNPC = function()
    local npcGuid = UnitGUID("target")
    if npcGuid then
        local _, _, _, _, _, npcIDStr = strsplit("-", npcGuid)
        if npcIDStr then
            local npcId = tonumber(npcIDStr)
            if AutoQuesting.private.disallowedNPCs.accept[npcId] then
                return false
            end
        end
    end

    return true
end

_AllQuestWindowsClosed = function()
    if ((not GossipFrame) or (not GossipFrame:IsVisible()))
        and ((not GossipFrameGreetingPanel) or (not GossipFrameGreetingPanel:IsVisible()))
        and ((not QuestFrameGreetingPanel) or (not QuestFrameGreetingPanel:IsVisible()))
        and ((not QuestFrameDetailPanel) or (not QuestFrameDetailPanel:IsVisible()))
        and ((not QuestFrameProgressPanel) or (not QuestFrameProgressPanel:IsVisible()))
        and ((not QuestFrameRewardPanel) or (not QuestFrameRewardPanel:IsVisible())) then
        return true
    end
    return false
end

return AutoQuesting
