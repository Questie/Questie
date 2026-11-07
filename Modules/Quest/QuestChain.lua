---@class QuestChain
local QuestChain = QuestieLoader:CreateModule("QuestChain")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

---Whether a quest's doable state rules it out for the player for good, unlike a missing level or prequest.
---@param doableState number A QuestieDB.DoableStates value
---@return boolean
local function _IsRuledOutForPlayer(doableState)
    local DoableStates = QuestieDB.DoableStates
    return doableState == DoableStates.WRONG_RACE or doableState == DoableStates.WRONG_CLASS or
        doableState == DoableStates.PROFESSION_MISSING or doableState == DoableStates.PROFESSION_SPECIALIZATION
end

---Follows nextQuestInChain from a quest and returns the follow-up quests in chain order. The walk stops before
---a quest Questie hides, a quest the player's race, class or professions rule out, and a quest it already
---passed, so a chain that loops back ends instead of repeating forever.
---@param questId QuestId
---@return QuestId[] nextQuestIds Empty when the quest has no follow-up the player could take
function QuestChain.GetNextQuests(questId)
    local nextQuestIds = {}
    local visited = {[questId] = true}

    local nextQuestId = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    while nextQuestId and nextQuestId > 0 and (not visited[nextQuestId]) and (not QuestieCorrections.hiddenQuests[nextQuestId]) do
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

return QuestChain
