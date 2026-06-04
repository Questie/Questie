---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local _StartStoppedTalkingTimer, _AllQuestWindowsClosed, _IsAllowedNPC, _IsQuestAllowedToAccept, _IsQuestAllowedToTurnIn, _ShouldAcceptByType

local shouldRunAuto = true

local function _IsFriend(playerName)
    if not playerName then
        return nil
    end
    local found = false
    pcall(function()
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
                            return
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
                        return
                    end
                end
            end
        end
    end)
    return found
end

function AutoQuesting.OnQuestDetail()
    if not shouldRunAuto then
        return
    end

    local source = "npc"
    local unitType = strsplit("-", UnitGUID("questnpc"))
    if unitType == "Player" then
        source = "player"
    end

    if Questie.db.profile.autoAccept.rejectSharedInBattleground and UnitInBattleground("player") and source == "player" then
        DeclineQuest()
        Questie:Print(l10n("Automatically rejected quest shared by player."))
        return
    end

    if source == "player" and Questie.db.profile.autoreject_nonfriend then
        local playerName = UnitName("questnpc")
        if playerName and _IsFriend(playerName) == false then
            DeclineQuest()
            Questie:Print(l10n("Automatically rejected quest shared by player."))
            return
        end
    end

    if (not Questie.db.profile.autoAccept.enabled) or AutoQuesting.IsModifierHeld() or (not _IsQuestAllowedToAccept()) then
        return
    end

    local questId = GetQuestID()
    if questId == 0 then
        return
    end

    if _ShouldAcceptByType(questId, Questie.db.profile.autoAccept, source) then
        AcceptQuest()
    end
end

function AutoQuesting.OnQuestGreeting()
    if (not shouldRunAuto) or AutoQuesting.IsModifierHeld() then
        shouldRunAuto = false
        return
    end

    if Questie.db.profile.autocomplete and _IsAllowedNPC() then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            if isComplete then
                SelectActiveQuest(index)
                return
            end
        end
    end

    if Questie.db.profile.autoAccept.enabled then
        if GetNumAvailableQuests() == 1 then
            SelectAvailableQuest(1)
        end
    end
end

function AutoQuesting.OnGossipShow()
    if (not shouldRunAuto) or AutoQuesting.IsModifierHeld() then
        shouldRunAuto = false
        return
    end

    if Questie.db.profile.autocomplete and _IsAllowedNPC() then
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
        if #availableQuests == 1 then
            QuestieCompat.SelectAvailableQuest(1)
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

---@param questId number
---@param toggles table @Toggles table from autoAccept (root or prefixed with npc_/player_)
---@param source string|nil @"npc" or "player" to use prefixed toggles, nil for root toggles
---@return boolean
_ShouldAcceptByType = function(questId, toggles, source)
    source = source or ""

    local function toggle(key)
        if source == "npc" then
            if toggles["npc_" .. key] ~= nil then
                return toggles["npc_" .. key]
            end
        elseif source == "player" then
            if toggles["player_" .. key] ~= nil then
                return toggles["player_" .. key]
            end
        end
        return toggles[key]
    end

    -- Check trivial (level-based)
    if not toggle("trivial") and QuestieDB.IsTrivial(QuestieDB.QueryQuestSingle(questId, "questLevel")) then
        return false
    end

    -- Determine quest types
    local isDaily = QuestieDB.IsDailyQuest(questId)
    local isPvP = QuestieDB.IsPvPQuest(questId)
    local isDungeon = QuestieDB.IsDungeonQuest(questId)
    local isRaid = QuestieDB.IsRaidQuest(questId)
    local isEvent = QuestieDB.IsActiveEventQuest(questId)
    local isRepeatable = QuestieDB.IsRepeatable(questId) and not isDaily and not isPvP
    local isNormal = not (isRepeatable or isDaily or isDungeon or isRaid or isPvP or isEvent)

    -- Accept if any matching type toggle is enabled
    if isDaily and toggle("daily") then return true end
    if isRepeatable and toggle("repeatable") then return true end
    if isDungeon and toggle("dungeon") then return true end
    if isRaid and toggle("raid") then return true end
    if isPvP and toggle("pvp") then return true end
    if isEvent and toggle("event") then return true end
    if isNormal and toggle("normal") then return true end

    return false
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

return AutoQuesting
