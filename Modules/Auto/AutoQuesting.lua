---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")
---@type TaintWatch
local TaintWatch = QuestieLoader:ImportModule("TaintWatch")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local _StartStoppedTalkingTimer, _AllQuestWindowsClosed, _IsAllowedNPC, _IsQuestAllowedToAccept, _IsQuestAllowedToTurnIn, _IsGossipQuestTrivial

local shouldRunAuto = true

function AutoQuesting.OnQuestDetail()
    if (not shouldRunAuto) or (not Questie.db.profile.autoAccept.enabled) or AutoQuesting.IsModifierHeld()
        or (not _IsAllowedNPC("questnpc")) or (not _IsQuestAllowedToAccept()) then
        return
    end

    local questId = GetQuestID()
    if questId == 0 then
        -- GetQuestID returns 0 when the dialog is closed. Nothing left to do for us
        return
    end

    if Questie.db.profile.autoAccept.rejectSharedInBattleground and UnitInBattleground("player") then
        local giverGuid = UnitGUID("questnpc")
        local unitType = giverGuid and strsplit("-", giverGuid)
        if unitType == "Player" then
            TaintWatch.Note("DeclineQuest")
            DeclineQuest()
            Questie:Print(l10n("Automatically rejected quest shared by player."))
            return
        end
    end

    -- Validate every disabled Auto Accept variant without letting later checks re-allow a rejected quest.
    local doAcceptQuest = true
    if (not Questie.db.profile.autoAccept.trivial) then
        local questLevel = QuestieDB.QueryQuestSingle(questId, "questLevel")
        doAcceptQuest = (not QuestieDB.IsTrivial(questLevel))
    end
    if (not Questie.db.profile.autoAccept.repeatable) then
        doAcceptQuest = doAcceptQuest and (not QuestieDB.IsRepeatable(questId))
    end
    if (not Questie.db.profile.autoAccept.pvp) then
        doAcceptQuest = doAcceptQuest and (not QuestieDB.IsPvPQuest(questId))
    end

    if doAcceptQuest then
        TaintWatch.Note("AcceptQuest")
        AcceptQuest()
    end
end

function AutoQuesting.OnQuestGreeting()
    if (not shouldRunAuto) or AutoQuesting.IsModifierHeld() or (not _IsAllowedNPC("npc")) then
        shouldRunAuto = false
        return
    end

    if Questie.db.profile.autocomplete then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            if isComplete then
                TaintWatch.Note("SelectActiveQuest")
                SelectActiveQuest(index)
                return
            end
        end
    end

    if Questie.db.profile.autoAccept.enabled then
        local availableQuestsCount = GetNumAvailableQuests()
        if availableQuestsCount > 0 then
            -- It is correct to use SelectAvailableQuest, instead of QuestieCompat.SelectAvailableQuest
            -- TODO: Do we want to call SelectAvailableQuest in QuestieCompat.SelectAvailableQuest when C_GossipInfo.GetAvailableQuests() is an empty table?
            local indexToAccept = 1
            if not Questie.db.profile.autoAccept.trivial then
                indexToAccept = 0
                local npcGuid = UnitGUID("npc")
                for i = 1, availableQuestsCount do
                    local questId = QuestieCompat.GetQuestGreetingQuestID(i, false, npcGuid)
                    local questLevel = questId > 0 and QuestieDB.QueryQuestSingle(questId, "questLevel") or nil
                    if not QuestieDB.IsTrivial(questLevel) then
                        indexToAccept = i
                        break
                    end
                end
            end

            if indexToAccept > 0 then
                TaintWatch.Note("SelectAvailableQuest")
                SelectAvailableQuest(indexToAccept)
            end
        end
    end
end

function AutoQuesting.OnGossipShow()
    if (not shouldRunAuto) or AutoQuesting.IsModifierHeld() or (not _IsAllowedNPC("npc")) then
        shouldRunAuto = false
        return
    end

    if Questie.db.profile.autocomplete then
        local completeQuests = QuestieCompat.GetActiveQuests()
        if #completeQuests > 0 then
            local firstCompleteQuestIndex = 0
            for i = 1, #completeQuests do
                local isComplete = completeQuests[i].isComplete
                if isComplete then
                    firstCompleteQuestIndex = i
                    break
                end
            end

            if firstCompleteQuestIndex > 0 then
                TaintWatch.Note("SelectActiveQuest")
                QuestieCompat.SelectActiveQuest(firstCompleteQuestIndex)
                return
            end
        end
    end

    if Questie.db.profile.autoAccept.enabled then
        local availableQuests = QuestieCompat.GetAvailableQuests()
        if #availableQuests > 0 then
            local indexToAccept = 0

            -- Skip per-quest filtering only when all Auto Accept variants are allowed.
            if Questie.db.profile.autoAccept.trivial and Questie.db.profile.autoAccept.repeatable and Questie.db.profile.autoAccept.pvp then
                indexToAccept = 1
            else
                for i = 1, #availableQuests do
                    local shouldAccept = true
                    if (not Questie.db.profile.autoAccept.trivial) then
                        if _IsGossipQuestTrivial(availableQuests[i]) then
                            shouldAccept = false
                        end
                    end
                    if (not Questie.db.profile.autoAccept.repeatable) then
                        local isRepeatable = availableQuests[i].repeatable
                        if isRepeatable then
                            shouldAccept = false
                        end
                    end
                    if (not Questie.db.profile.autoAccept.pvp) then
                        local isPvP = QuestieDB.IsPvPQuest(availableQuests[i].questID)
                        if isPvP then
                            shouldAccept = false
                        end
                    end

                    if shouldAccept then
                        indexToAccept = i
                        break
                    end
                end
            end

            if indexToAccept > 0 then
                TaintWatch.Note("SelectAvailableQuest")
                QuestieCompat.SelectAvailableQuest(indexToAccept)
            end
        end
    end
end

function AutoQuesting.OnGossipClosed()
    _StartStoppedTalkingTimer()
end

function AutoQuesting.OnQuestFinished()
    _StartStoppedTalkingTimer()
end

function AutoQuesting.OnQuestProgress()
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or AutoQuesting.IsModifierHeld()
        or (not IsQuestCompletable()) or (not _IsQuestAllowedToTurnIn()) or (not _IsAllowedNPC("questnpc")) then
        return
    end

    TaintWatch.Note("CompleteQuest")
    CompleteQuest()
end

function AutoQuesting.OnQuestAcceptConfirm()
    if (not Questie.db.profile.autoAccept.enabled) then
        return
    end

    TaintWatch.Note("ConfirmAcceptQuest")
    ConfirmAcceptQuest()
end

function AutoQuesting.OnQuestComplete()
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or AutoQuesting.IsModifierHeld()
        or GetNumQuestChoices() > 1 or (not _IsQuestAllowedToTurnIn()) or (not _IsAllowedNPC("questnpc")) then
        return
    end

    TaintWatch.Note("GetQuestReward")
    GetQuestReward(1)
end

function AutoQuesting.Reset()
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
    ["shift"] = function()
        return IsShiftKeyDown()
    end,
    ["ctrl"] = function()
        return IsControlKeyDown()
    end,
    ["alt"] = function()
        return IsAltKeyDown()
    end,
    ["disabled"] = function() return false; end,
}

---@return boolean @True if the modifier key is held down, false otherwise
function AutoQuesting.IsModifierHeld()
    local bind = Questie.db.profile.autoModifier
    if (not bind) then
        return false
    end

    return bindTruthTable[bind]()
end

---@param unit string
---@return boolean
_IsAllowedNPC = function(unit)
    -- The selected target can be unrelated to an item offer or the open dialog.
    local npcGuid = UnitGUID(unit)
    if issecretvalue and issecretvalue(npcGuid) then
        -- Leave the interaction manual when the NPC's automation exclusions cannot be checked.
        return false
    end
    if npcGuid then
        local kind, _, _, _, _, npcIDStr = strsplit("-", npcGuid)
        if kind == "Creature" or kind == "Vehicle" then
            local npcId = tonumber(npcIDStr)
            if AutoQuesting.private.disallowedNPCs[npcId] then
                return false
            end
        end
    end

    return true
end

---@param quest GossipQuestUIInfo
---@return boolean?
_IsGossipQuestTrivial = function(quest)
    local questLevel = quest.questLevel
    if quest.questID and quest.questID > 0 then
        questLevel = QuestieDB.QueryQuestSingle(quest.questID, "questLevel") or questLevel
    end
    if questLevel == nil then
        return quest.isTrivial
    end

    return QuestieDB.IsTrivial(questLevel)
end

_IsQuestAllowedToAccept = function()
    local questId = GetQuestID()
    if questId > 0 then
        if AutoQuesting.private.disallowedQuests.accept[questId] then
            return false
        end

        local questTagId = QuestieDB.GetQuestTagInfo(questId)
        if questTagId == QuestieDB.questTagIds.ESCORT then
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
