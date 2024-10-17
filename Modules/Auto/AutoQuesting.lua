---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local _IsBindTrue, _StartStoppedTalkingTimer, _AllQuestWindowsClosed, _IsAllowedToAcceptFromNPC, _IsQuestAllowedToAccept, _IsQuestAllowedToTurnIn

local shouldRunAuto = true

local INDIZES_AVAILABLE = 7
local INDIZES_COMPLETE = 6

function AutoQuesting.OnQuestDetail()
    print("AutoQuesting.OnQuestDetail", _AllQuestWindowsClosed())
    if (not shouldRunAuto) or (not Questie.db.profile.autoaccept) or _IsBindTrue(Questie.db.profile.autoModifier) or (not _IsAllowedToAcceptFromNPC()) or (not _IsQuestAllowedToAccept()) then
        return
    end

    local doAcceptQuest = false
    if Questie.db.profile.acceptTrivial then
        doAcceptQuest = true
    else
        local questId = GetQuestID()
        local questLevel = QuestieDB.QueryQuestSingle(questId, "questLevel")
        doAcceptQuest = (not QuestieDB.IsTrivial(questLevel))
    end

    if doAcceptQuest then
        AcceptQuest()
    end
end

function AutoQuesting.OnQuestGreetings()
    print("AutoQuesting.OnQuestGreetings", _AllQuestWindowsClosed())
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
    print("AutoQuesting.OnGossipShow", _AllQuestWindowsClosed())
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
            local indexToAccept = 0
            if Questie.db.profile.acceptTrivial then
                indexToAccept = 1
            else
                -- Check if there is a non-trivial quest available
                for isTrivialIndex = 3, #availableQuests, INDIZES_AVAILABLE do
                    local isTrivial = availableQuests[isTrivialIndex]
                    if (not isTrivial) then
                        indexToAccept = math.floor(isTrivialIndex / INDIZES_AVAILABLE) + 1
                        break
                    end
                end
            end

            if indexToAccept > 0 then
                QuestieCompat.SelectAvailableQuest(indexToAccept)
            end
        end
    end
end

function AutoQuesting.OnGossipClosed()
    print("AutoQuesting.OnGossipClosed", _AllQuestWindowsClosed(), shouldRunAuto)
    _StartStoppedTalkingTimer()
end

function AutoQuesting.OnQuestFinished()
    print("AutoQuesting.OnQuestFinished", _AllQuestWindowsClosed(), shouldRunAuto)
    _StartStoppedTalkingTimer()
end

function AutoQuesting.OnQuestAccepted()
    print("AutoQuesting.OnQuestAccepted", _AllQuestWindowsClosed())
end

function AutoQuesting.OnQuestProgress()
    print("AutoQuesting.OnQuestProgress", _AllQuestWindowsClosed())
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or (not IsQuestCompletable()) or (not _IsQuestAllowedToTurnIn()) then
        return
    end

    CompleteQuest()
end

function AutoQuesting.OnQuestAcceptConfirm()
    print("AutoQuesting.OnQuestAcceptConfirm", _AllQuestWindowsClosed())
    if (not Questie.db.profile.autoaccept) then
        return
    end

    ConfirmAcceptQuest()
end

function AutoQuesting.OnQuestComplete()
    print("AutoQuesting.OnQuestComplete", _AllQuestWindowsClosed())
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or GetNumQuestChoices() > 1 then
        return
    end

    GetQuestReward(1)
end

function AutoQuesting.Reset()
    print("AutoQuesting.Reset")
    shouldRunAuto = true
end

_StartStoppedTalkingTimer = function()
    -- We need to wait a bit, because in between quest dialogs, there is a short time where all windows are closed.
    -- Without waiting we would reset while we are actually still talking to the NPC.
    C_Timer.After(0.5, function()
        if (not shouldRunAuto) and _AllQuestWindowsClosed() then
            AutoQuesting.Reset()
        end
    end)
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
        and ((not QuestFrameRewardPanel) or (not QuestFrameRewardPanel:IsVisible()))
        -- Immersion addon support
        and ((not ImmersionFrame) or (not ImmersionFrame.TitleButtons) or (not ImmersionFrame.TitleButtons:IsVisible()))
        and ((not ImmersionContentFrame) or (not ImmersionContentFrame:IsVisible())) --
    then
        return true
    end
    return false
end

return AutoQuesting
