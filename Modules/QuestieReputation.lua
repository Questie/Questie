---@class QuestieReputation
local QuestieReputation = QuestieLoader:CreateModule("QuestieReputation")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local playerReputations = {}

local _ReachedNewStanding, _WinterSaberChanged

-- Fast local references
local ExpandFactionHeader, GetNumFactions, GetFactionInfo = ExpandFactionHeader, GetNumFactions, GetFactionInfo
local tinsert, floor = table.insert, math.floor

--- Updates all factions a player already discovered and checks if any of these
--- reached a new reputation level
---@param isInit boolean? @
function QuestieReputation:Update(isInit)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieReputation: Update")
    ExpandFactionHeader(0) -- Expand all header

    local factionChanged = false
    local newFaction = false

    for i=1, GetNumFactions() do
        local name, _, standingId, _, _, barValue, _, _, isHeader, _, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if not isHeader and factionID then
            local previousValues = playerReputations[factionID]
            if (not previousValues) then
                --? Reset all autoBlacklisted quests if a faction gets discovered
                QuestieQuest.ResetAutoblacklistCategory("rep")
                newFaction = true
            end

            playerReputations[factionID] = {standingId, barValue}

            if (not isInit) and (
                    _ReachedNewStanding(previousValues, standingId)
                    or _WinterSaberChanged(factionID, previousValues, barValue)) then
                Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieReputation: Update - faction \"" .. name .. "\" (" .. factionID .. ") changed")
                factionChanged = true
            end
        end
    end

    return factionChanged, newFaction
end

---@return boolean
_ReachedNewStanding = function(previousValues, standingId)
    return (not previousValues) -- New faction
        or (previousValues[1] ~= standingId) -- Standing changed
end

---@return boolean
_WinterSaberChanged = function(factionID, previousValues, barValue)
    return factionID == 589 -- Wintersaber Trainer
        and previousValues and ((previousValues[2] < 4500 and barValue >= 4500)
            or (previousValues[2] < 13000 and barValue >= 13000))
end

-- This function is just for debugging purpose
-- There is no need to access the playerReputations table somewhere else
function QuestieReputation:GetPlayerReputations()
    return playerReputations
end

---@param requiredMinRep { [1]: number, [2]: number }? [1] = factionId, [2] = repValue
---@param requiredMaxRep { [1]: number, [2]: number }? [1] = factionId, [2] = repValue
---@return boolean AboveMinRep
---@return boolean HasMinFaction
---@return boolean BelowMaxRep
---@return boolean HasMaxFaction
function QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)
    local aboveMinRep = false -- the player has reached the min required reputation value
    local belowMaxRep = false
    local hasMinFaction = false
    local hasMaxFaction = false

    if requiredMinRep then
        local minFactionID = requiredMinRep[1]
        local reqMinValue = requiredMinRep[2]

        if playerReputations[minFactionID] then
            hasMinFaction = true
            aboveMinRep = playerReputations[minFactionID][2] >= reqMinValue
        end
    else
        -- If requiredMinRep is nil, we don't care about the reputation aka it fullfils it
        aboveMinRep = true
        hasMinFaction = true
    end
    if requiredMaxRep then
        local maxFactionID = requiredMaxRep[1]
        local reqMaxValue = requiredMaxRep[2]

        if playerReputations[maxFactionID] then
            hasMaxFaction = true
            belowMaxRep = playerReputations[maxFactionID][2] < reqMaxValue
        elseif maxFactionID == 909 then -- Darkmoon Faire
            hasMaxFaction = true
            belowMaxRep = true
        end
    else
        -- If requiredMaxRep is nil, we don't care about the reputation aka it fullfils it
        belowMaxRep = true
        hasMaxFaction = true
    end
    return aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction
end

--- Checkout https://github.com/Questie/Questie/wiki/Corrections#reputation-levels for more information
---@return boolean HasReputation Is the player within the required reputation ranges specified by the parameters
function QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep)
    local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

    return ((aboveMinRep and hasMinFaction) and (belowMaxRep and hasMaxFaction))
end

-- Using https://wago.tools/db2/QuestFactionReward?build=4.4.0.54217
local reputationRewards = {
    [1] = 10,
    [2] = 25,
    [3] = 75,
    [4] = 150,
    [5] = 250,
    [6] = 350,
    [7] = 500,
    [8] = 1000,
    [9] = 5,
    -- Somehow quests also reward different values than the DBC lists :shrug:
    [10] = 1400,
    [11] = 2000,
    [12] = 300,
    [13] = 60,
    [14] = 1500,
}

---@param questId QuestId
---@return ReputationPair[]
function QuestieReputation.GetReputationReward(questId)
    local reputationReward = QuestieDB.QueryQuestSingle(questId, "reputationReward")

    if (not reputationReward) then
        return {}
    end

    if Expansions.Current <= Expansions.Wotlk then
        return reputationReward
    end

    local rewards = {}
    local knowsMrPopularityRank1 = IsSpellKnown(78634)
    local knowsMrPopularityRank2 = IsSpellKnown(78635)
    for _, entry in pairs(reputationReward) do
        -- corrections for quests before cataclysm are still applied to cataclysm quests.
        -- Therefore they most likely don't match any entry reputationRewards. We work around with "or entry[2]"
        local reward
        if entry[2] > 0 then
            reward = reputationRewards[entry[2]] or entry[2]
        elseif entry[2] < 0 then
            local rewardEntry = reputationRewards[-entry[2]]
            reward = rewardEntry and -rewardEntry or entry[2]
        end

        if reward then
            if knowsMrPopularityRank2 then
                reward = floor(reward * 1.1) -- 10% bonus reputation from Mr. Popularity Rank 2
            elseif knowsMrPopularityRank1 then
                reward = floor(reward * 1.05) -- 5% bonus reputation from Mr. Popularity Rank 1
            end
            tinsert(rewards, {entry[1], reward})
        end
    end

    return rewards
end

return QuestieReputation
