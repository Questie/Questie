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

---Follows nextQuestInChain from a quest and returns the follow-up quests in chain order. The walk stops before
---a quest missing from the database, a quest Questie hides, a quest the player's race, class or professions
---rule out, a quest a turned-in quest made unavailable, and a quest it already passed, so a chain that loops
---back ends instead of repeating forever.
---@param questId QuestId
---@return QuestId[] nextQuestIds Empty when the quest has no follow-up the player could take
function QuestChain.GetNextQuests(questId)
    local nextQuestIds = {}
    local visited = {[questId] = true}

    local nextQuestId = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    while nextQuestId and nextQuestId > 0 and (not visited[nextQuestId]) and QuestieDB.QuestPointers[nextQuestId] and
        (not QuestieCorrections.hiddenQuests[nextQuestId]) do
        local _, _, doableState = QuestieDB.IsDoableVerbose(nextQuestId, false, true, true)
        if _IsRuledOutForPlayer(doableState) then
            break
        end

        visited[nextQuestId] = true
        nextQuestIds[#nextQuestIds + 1] = nextQuestId
        nextQuestId = QuestieDB.QueryQuestSingle(nextQuestId, "nextQuestInChain")
    end

    return nextQuestIds
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
