---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local _StartStoppedTalkingTimer, _AllQuestWindowsClosed, _IsAllowedNPC, _IsQuestAllowedToAccept, _IsQuestAllowedToTurnIn

local shouldRunAuto = true

--- Checks if the given player is on the friends list. Returns nil when no player name is given.
---@param playerName string|nil
---@return boolean|nil
local function _IsFriend(playerName)
    if not playerName then
        return nil
    end
    local found = false
    local basePlayerName = strsplit("-", playerName)

    if C_FriendList then
        local numFriends = type(C_FriendList.GetNumFriends) == "function" and C_FriendList.GetNumFriends() or 0
        if type(numFriends) == "number" and numFriends > 0 then
            for i = 1, numFriends do
                local friendInfo
                if type(C_FriendList.GetFriendInfoByIndex) == "function" then
                    friendInfo = C_FriendList.GetFriendInfoByIndex(i)
                elseif type(C_FriendList.GetFriendInfo) == "function" then
                    friendInfo = C_FriendList.GetFriendInfo(i)
                end
                if friendInfo then
                    local friendName
                    if type(friendInfo) == "table" then
                        friendName = friendInfo.name
                    elseif type(friendInfo) == "string" then
                        friendName = friendInfo
                    end
                    if friendName and strsplit("-", friendName) == basePlayerName then
                        found = true
                        break
                    end
                end
            end
        end
    end

    if not found and type(GetFriendInfo) == "function" then
        local numFriends = GetNumFriends()
        if type(numFriends) == "number" and numFriends > 0 then
            for i = 1, numFriends do
                local name = GetFriendInfo(i)
                if name and strsplit("-", name) == basePlayerName then
                    found = true
                    break
                end
            end
        end
    end

    if not found and C_BattleNet and type(BNGetNumFriends) == "function" then
        local numBnetFriends = BNGetNumFriends()
        if type(numBnetFriends) == "number" and numBnetFriends > 0 then
            for i = 1, numBnetFriends do
                local gameAccounts = {}
                if type(C_BattleNet.GetFriendAccountInfo) == "function" then
                    gameAccounts[#gameAccounts + 1] = C_BattleNet.GetFriendAccountInfo(i)
                end
                if type(C_BattleNet.GetFriendNumGameAccounts) == "function" and type(C_BattleNet.GetFriendGameAccountInfo) == "function" then
                    local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(i)
                    if type(numGameAccounts) == "number" and numGameAccounts > 0 then
                        for j = 1, numGameAccounts do
                            gameAccounts[#gameAccounts + 1] = C_BattleNet.GetFriendGameAccountInfo(i, j)
                        end
                    end
                end
                for _, accountInfo in ipairs(gameAccounts) do
                    local characterName = accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.characterName
                    if characterName and strsplit("-", characterName) == basePlayerName then
                        found = true
                        break
                    end
                end
            end
        end
    end

    return found
end

function AutoQuesting.OnQuestDetail()
    local guid = UnitGUID("questnpc")
    local unitType = guid and strsplit("-", guid)

    -- The Auto Reject settings work independently of the Auto Accept master switch.
    if (not AutoQuesting.IsModifierHeld()) and unitType == "Player" then
        if Questie.db.profile.autoAccept.rejectSharedInBattleground and UnitInBattleground("player") then
            DeclineQuest()
            Questie:Print(l10n("Automatically rejected quest shared by player."))
            return
        end

        if Questie.db.profile.autoreject_nonfriend then
            local playerName = UnitName("questnpc")
            if playerName and _IsFriend(playerName) == false then
                DeclineQuest()
                Questie:Print(l10n("Automatically rejected quest shared by player."))
                return
            end
        end
    end

    if (not shouldRunAuto) or (not Questie.db.profile.autoAccept.enabled) or AutoQuesting.IsModifierHeld() or (not _IsAllowedNPC()) or (not _IsQuestAllowedToAccept()) then
        return
    end

    local questId = GetQuestID()
    if questId == 0 then
        -- GetQuestID returns 0 when the dialog is closed. Nothing left to do for us
        return
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
        AcceptQuest()
    end
end

function AutoQuesting.OnQuestGreeting()
    if (not shouldRunAuto) or AutoQuesting.IsModifierHeld() or (not _IsAllowedNPC()) then
        shouldRunAuto = false
        return
    end

    if Questie.db.profile.autocomplete then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            if isComplete then
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
            SelectAvailableQuest(1)
        end
    end
end

function AutoQuesting.OnGossipShow()
    if (not shouldRunAuto) or AutoQuesting.IsModifierHeld() or (not _IsAllowedNPC()) then
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
                        local isTrivial = availableQuests[i].isTrivial
                        if isTrivial then
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
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or AutoQuesting.IsModifierHeld() or (not IsQuestCompletable()) or (not _IsQuestAllowedToTurnIn()) or (not _IsAllowedNPC()) then
        return
    end

    CompleteQuest()
end

function AutoQuesting.OnQuestAcceptConfirm(_, playerName)
    if (not Questie.db.profile.autoAccept.enabled) then
        return
    end

    if Questie.db.profile.autoreject_nonfriend and playerName then
        if _IsFriend(playerName) == false then
            DeclineQuest()
            Questie:Print(l10n("Automatically rejected quest shared by player."))
            return
        end
    end

    ConfirmAcceptQuest()
end

function AutoQuesting.OnQuestComplete()
    if (not shouldRunAuto) or (not Questie.db.profile.autocomplete) or AutoQuesting.IsModifierHeld() or GetNumQuestChoices() > 1 or (not _IsQuestAllowedToTurnIn()) or (not _IsAllowedNPC()) then
        return
    end

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

_IsAllowedNPC = function()
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