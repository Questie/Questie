---@class QuestChain
local QuestChain = QuestieLoader:CreateModule("QuestChain")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestLockReasons
local QuestLockReasons = QuestieLoader:ImportModule("QuestLockReasons")
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local GetCoinTextureString = C_CurrencyInfo.GetCoinTextureString or GetCoinTextureString

---Whether a quest's doable state rules it out for the player for good, unlike a missing level or prequest.
---A quest that a turned-in quest made unavailable counts too, unlike one an active quest blocks.
---@param doableState number A QuestieDB.DoableStates value
---@return boolean
local function _IsRuledOutForPlayer(doableState)
    local DoableStates = QuestieDB.DoableStates
    return doableState == DoableStates.WRONG_RACE or doableState == DoableStates.WRONG_CLASS or
        doableState == DoableStates.PROFESSION_MISSING or doableState == DoableStates.PROFESSION_SPECIALIZATION or
        doableState == DoableStates.EXCLUSIVE_COMPLETED or doableState == DoableStates.DISABLING_QUEST_COMPLETED
end

---Whether the player could take a quest: Questie does not hide it, and neither the player's race, class or
---professions nor a turned-in quest rule it out.
---@param questId QuestId
---@return boolean
local function _IsTakeable(questId)
    if QuestieCorrections.hiddenQuests[questId] then
        return false
    end
    local _, _, doableState = QuestieDB.IsDoableVerbose(questId, false, true, true)
    return not _IsRuledOutForPlayer(doableState)
end

---Whether a quest belongs in a full chain: Questie does not hide it for good. Quests hidden only on the map and
---world event quests, which Questie hides while their event is not running, still belong.
---@param questId QuestId
---@return boolean
local function _IsListedInFullChain(questId)
    local hiddenState = QuestieCorrections.hiddenQuests[questId]
    return (not hiddenState) or hiddenState == QuestieQuestBlacklist.HIDE_ON_MAP or QuestieEvent.IsEventQuest(questId)
end

---Follows nextQuestInChain from a quest and returns the follow-up quests in chain order. The walk stops before a
---quest isListed rejects, a quest missing from the database, and a quest it already passed, so a chain that loops
---back ends instead of repeating forever.
---@param questId QuestId
---@param isListed fun(questId: QuestId): boolean
---@return QuestId[]
local function _FollowChain(questId, isListed)
    local followUpQuestIds = {}
    local visited = {[questId] = true}

    local nextQuestId = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    while nextQuestId and nextQuestId > 0 and (not visited[nextQuestId]) and QuestieDB.QuestPointers[nextQuestId] and
        isListed(nextQuestId) do
        visited[nextQuestId] = true
        followUpQuestIds[#followUpQuestIds + 1] = nextQuestId
        nextQuestId = QuestieDB.QueryQuestSingle(nextQuestId, "nextQuestInChain")
    end

    return followUpQuestIds
end

---Returns the follow-up quests of a quest in chain order, up to the first one the player could not take: one
---Questie hides, or one the player's race, class or professions or a turned-in quest rule out.
---@param questId QuestId
---@return QuestId[] nextQuestIds Empty when the quest has no follow-up the player could take
function QuestChain.GetNextQuests(questId)
    return _FollowChain(questId, _IsTakeable)
end

---Returns all follow-up quests of a quest in chain order, the ones the player cannot take included. Only a quest
---Questie hides for good ends the chain early; GetLockReasons tells why the player cannot take the others.
---@param questId QuestId
---@return QuestId[] followUpQuestIds Empty when the quest has no follow-up
function QuestChain.GetFollowUpQuests(questId)
    return _FollowChain(questId, _IsListedInFullChain)
end

---Lists why the player cannot take each follow-up quest of a chain. A quest without reasons of its own that comes
---after one with reasons gets those, as the player cannot reach it either. A quest the player has turned in or has
---in the quest log gets none, and so do the quests after it until one has reasons of its own.
---@param questId QuestId The quest the chain is followed from
---@param followUpQuestIds QuestId[] Its follow-up quests, as GetFollowUpQuests returns them
---@return table<QuestId, string[]> reasonsByQuestId An empty list for each quest the player can take
function QuestChain.GetLockReasons(questId, followUpQuestIds)
    local reasonsByQuestId = {}
    -- Requiring the quests the chain leads through is no reason
    local chainQuestIds = {[questId] = true}
    local inheritedReasons = {}

    for _, followUpQuestId in ipairs(followUpQuestIds) do
        if Questie.db.char.complete[followUpQuestId] or ActiveQuests.Get(followUpQuestId) then
            inheritedReasons = {}
        else
            local reasons = QuestLockReasons.GetReasons(followUpQuestId, chainQuestIds)
            if reasons[1] then
                inheritedReasons = reasons
            end
        end
        reasonsByQuestId[followUpQuestId] = inheritedReasons
        chainQuestIds[followUpQuestId] = true
    end

    return reasonsByQuestId
end

---Returns the XP and money a quest rewards, as listed next to quests in a chain: the XP in the color of the
---quest's difficulty for the player, the money as coins. A reward that is zero is left out.
---@param questId QuestId
---@return string rewardText Empty when the quest rewards neither
function QuestChain.GetRewardText(questId)
    local xpText = ""
    local xpReward = QuestXP:GetQuestLogRewardXP(questId, Questie.db.profile.showQuestXpAtMaxLevel)
    if xpReward > 0 then
        local questLevel = QuestieLib.GetEffectiveQuestLevel(questId)
        xpText = QuestieLib:PrintDifficultyColor(questLevel, l10n("(") .. FormatLargeNumber(xpReward) .. l10n("xp") .. l10n(")") .. " ",
            QuestieDB.IsRepeatable(questId), QuestieEvent.IsEventQuest(questId), QuestieDB.IsPvPQuest(questId), questId)
    end

    local moneyText = ""
    local moneyReward = QuestXP.GetQuestRewardMoney(questId)
    if moneyReward > 0 then
        moneyText = Questie:Colorize(l10n("(") .. GetCoinTextureString(moneyReward) .. l10n(")") .. " ", "white")
    end

    return xpText .. moneyText
end

return QuestChain
