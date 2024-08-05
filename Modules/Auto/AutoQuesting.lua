---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")

local _IsBindTrue, _AllQuestWindowsClosed, _IsAllowedToAcceptFromNPC, _IsQuestAllowedToAccept, _IsQuestAllowedToTurnIn

local shouldRunAuto = true

local INDIZES_AVAILABLE = 7
local INDIZES_COMPLETE = 6

function AutoQuesting.OnQuestDetail()
    print("AutoQuesting.OnQuestDetail")
    if (not shouldRunAuto) or (not Questie.db.profile.autoaccept) or _IsBindTrue(Questie.db.profile.autoModifier) or (not _IsAllowedToAcceptFromNPC()) or (not _IsQuestAllowedToAccept()) then
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
        -- It is correct to use SelectAvailableQuest, instead of QuestieCompat.SelectAvailableQuest
        -- TODO: Do we want to call SelectAvailableQuest in QuestieCompat.SelectAvailableQuest when C_GossipInfo.GetAvailableQuests() is an empty table?
        SelectAvailableQuest(1)
    end
end

function AutoQuesting.OnGossipShow()
    print("AutoQuesting.OnGossipShow")
    if (not shouldRunAuto) or _IsBindTrue(Questie.db.profile.autoModifier) or (not _IsAllowedToAcceptFromNPC()) then
        shouldRunAuto = false
        return
    end

    local availableQuests = { QuestieCompat.GetAvailableQuests() }

    if Questie.db.profile.autocomplete then
        local completeQuests = { QuestieCompat.GetActiveQuests() }
        if #completeQuests > 0 then
            local firstCompleteQuestIndex = 0
            for i = 1, #completeQuests, INDIZES_COMPLETE do
                local isComplete = completeQuests[i + 3]
                if isComplete then
                    firstCompleteQuestIndex = math.floor(i / INDIZES_COMPLETE) + 1
                    break
                end
            end

            if firstCompleteQuestIndex > 0 then
                QuestieCompat.SelectActiveQuest(firstCompleteQuestIndex)
                return
            end
        end
    end

    if Questie.db.profile.autoaccept then
        if #availableQuests > 0 then
            QuestieCompat.SelectAvailableQuest(1)
        end
    end
end

function AutoQuesting.OnGossipClosed()
    print("AutoQuesting.OnGossipClosed")
end

function AutoQuesting.OnQuestFinished()
    print("AutoQuesting.OnQuestFinished")

    C_Timer.After(0.5, function()
        if (not shouldRunAuto) and _AllQuestWindowsClosed() then
            AutoQuesting.Reset()
        end
    end)
end

function AutoQuesting.OnQuestAccepted()
    print("AutoQuesting.OnQuestAccepted")
end

function AutoQuesting.OnQuestProgress()
    print("AutoQuesting.OnQuestProgress")
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or (not IsQuestCompletable()) or (not _IsQuestAllowedToTurnIn()) then
        return
    end

    CompleteQuest()
end

function AutoQuesting.OnQuestAcceptConfirm()
    print("AutoQuesting.OnQuestAcceptConfirm")
    if (not Questie.db.profile.autoaccept) then
        return
    end

    ConfirmAcceptQuest()
end

function AutoQuesting.OnQuestComplete()
    print("AutoQuesting.OnQuestComplete")
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or GetNumQuestChoices() > 1 then
        return
    end

    GetQuestReward(1)
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
            if AutoQuesting.private.disallowedNPCs[npcId] then
                return false
            end
        end
    end

    return true
end

_IsQuestAllowedToAccept = function()
    local questId = GetQuestID()
    if questId > 0 then
        if AutoQuesting.private.disallowedQuests.accept[questId] then
            return false
        end
    end

    return true
end

_IsQuestAllowedToTurnIn = function()
    local questId = GetQuestID()
    if questId > 0 then
        if AutoQuesting.private.disallowedQuests.turnIn[questId] then
            return false
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
