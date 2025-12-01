---@class QuestieReputation
local QuestieReputation = QuestieLoader:CreateModule("QuestieReputation")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local playerReputations = {}

local _ReachedNewStanding, _WinterSaberChanged, _GetRewardMultiplier, _GetBuffMultiplier, _FilterShaTarRewards

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
        local name, description, standingId, _, _, barValue, _, _, _, _, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if factionID and description then -- we use description instead of isHeader because some factions are header (e.g. The Tillers)
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

    if Expansions.Current >= Expansions.MoP then
        local nomiFactionId = QuestieDB.factionIDs.NOMI
        playerReputations[nomiFactionId] = {4, 0} -- Nomi, Neutral 0 rep
        local repInfo = C_GossipInfo.GetFriendshipReputation(nomiFactionId)
        local standingId
        if repInfo and repInfo.standing >= 0 then
            if repInfo.standing < 3000 then
                standingId = 4
            elseif repInfo.standing < 9000 then
                standingId = 5
            elseif repInfo.standing < 21000 then
                standingId = 6
            elseif repInfo.standing < 42000 then
                standingId = 7
            else
                standingId = 8
            end
            playerReputations[nomiFactionId] = {standingId, repInfo.standing}
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
    return factionID == QuestieDB.factionIDs.WINTERSABER_TRAINERS
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
        elseif maxFactionID == QuestieDB.factionIDs.DARKMOON_FAIRE then
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
function QuestieReputation.HasReputation(requiredMinRep, requiredMaxRep)
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
    [15] = 400,
    [16] = 275,
    [17] = 1800,
    [18] = 2600,
    [19] = 3000,
    [20] = 3300,
    [21] = 7000,
    [22] = 900,
    [23] = 540,
    [24] = 700,
    [25] = 999,
    [26] = 6000,
    [27] = 20,
    [28] = 50,
    [29] = 2850,
    [30] = 130,
    [31] = 200,
    [32] = 450,
    [33] = 100,
    [34] = 3750,
    [35] = 5000,
    [36] = 750,
    [37] = 1050,
}

---@param questId QuestId
---@return ReputationPair[]
function QuestieReputation.GetReputationReward(questId)
    local reputationReward = QuestieDB.QueryQuestSingle(questId, "reputationReward")

    if (not reputationReward) then
        return {}
    end

    local factionIDs = QuestieDB.factionIDs
    if Expansions.Current >= Expansions.Tbc then
        reputationReward = _FilterShaTarRewards(reputationReward, factionIDs)
    end

    -- Add Aldor/Scryer penalty to quests from the opposite faction
    for _, entry in pairs(reputationReward) do
        local factionId = entry[1]
        local value = entry[2]
        if Expansions.Current > Expansions.Wotlk then
            value = reputationRewards[value]
        end
        if factionId == factionIDs.THE_ALDOR then
            value = 0 - floor(value * 1.1)
            tinsert(reputationReward, {factionIDs.THE_SCRYERS, value})
            break
        elseif factionId == factionIDs.THE_SCRYERS then
            value = 0 - floor(value * 1.1)
            tinsert(reputationReward, {factionIDs.THE_ALDOR, value})
            break
        end
    end

    local rewards = {}
    local reputationMultiplier = _GetRewardMultiplier()

    for _, entry in pairs(reputationReward) do
        local factionId = entry[1]
        local reward = entry[2]

        if Expansions.Current > Expansions.Wotlk then
            -- In the base DBs for Cata and beyond a reputation mapping is used instead of the raw values from the quest.
            -- Also corrections for quests before cataclysm are still applied to cataclysm quests.
            -- Therefore they most likely don't match any entry reputationRewards. We work around with "or entry[2]"
            if entry[2] > 0 then
                reward = reputationRewards[entry[2]] or entry[2]
            elseif entry[2] < 0 then
                local rewardEntry = reputationRewards[-entry[2]]
                reward = rewardEntry and -rewardEntry or entry[2]
            end
        end

        if reward then
            reward = reward * reputationMultiplier
            -- faction bonus commendation check
            if select(15, GetFactionInfoByID(factionId)) == true then
                reward = reward * 2
            end

            tinsert(rewards, {factionId, reward})
        end
    end

    return rewards
end

_GetRewardMultiplier = function()
    local knowsMrPopularityRank1 = IsSpellKnown(78634)
    local knowsMrPopularityRank2 = IsSpellKnown(78635)
    local buffMultiplier = _GetBuffMultiplier()
    local playerIsHuman = QuestiePlayer.HasRequiredRace(QuestieDB.raceKeys.HUMAN)
    local multiplier = 1 + buffMultiplier

    if playerIsHuman then
        multiplier = multiplier + 0.1 -- 10% bonus reputation from Human Racial
    end

    if knowsMrPopularityRank2 then
        multiplier = multiplier + 0.1 -- 10% bonus reputation from Mr. Popularity Rank 2
    elseif knowsMrPopularityRank1 then
        multiplier = multiplier + 0.05 -- 5% bonus reputation from Mr. Popularity Rank 1
    end

    return multiplier
end

---@return number
_GetBuffMultiplier = function()
    local buffMultiplier = 0
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId, _ = UnitAura("player", i, "HELPFUL")
        if spellId == nil then
            break
        end

        if spellId == 46668 then
            buffMultiplier = buffMultiplier + 0.1 -- 10% bonus reputation from Darkmoon Faire buff
        elseif spellId == 95987 then
            buffMultiplier = buffMultiplier + 0.1 -- 10% bonus reputation from Unburdened (Hallow's End Alliance)
        elseif spellId == 24705 then
            buffMultiplier = buffMultiplier + 0.1 -- 10% bonus reputation from Grim Visage (Hallow's End Horde)
        end
    end

    return buffMultiplier
end

---@param reputationReward ReputationPair[]
---@param factionIDs table
_FilterShaTarRewards = function(reputationReward, factionIDs)
    local playerIsHonoredWithShaTar = QuestieReputation.HasReputation({ factionIDs.THE_SHA_TAR, 9000 }, nil)
    -- filter out Sha'Tar reputation rewards when quest also rewards Aldor/Scryer reputation and the player is already honored with them Sha'Tar
    if playerIsHonoredWithShaTar then
        local hasAldorOrScryer = false
        for _, entry in pairs(reputationReward) do
            local factionId = entry[1]
            if factionId == factionIDs.THE_ALDOR or factionId == factionIDs.THE_SCRYERS then
                hasAldorOrScryer = true
                break
            end
        end

        if hasAldorOrScryer then
            local filteredReputationReward = {}
            for _, entry in pairs(reputationReward) do
                local factionId = entry[1]
                if factionId ~= factionIDs.THE_SHA_TAR then
                    tinsert(filteredReputationReward, entry)
                end
            end
            reputationReward = filteredReputationReward
        end
    end

    return reputationReward
end

---@param factionId FactionId
---@return string name @Name of the faction
function QuestieReputation.GetFactionName(factionId)
    local friendReputation = C_GossipInfo.GetFriendshipReputation(factionId)
    if friendReputation and friendReputation.name and friendReputation.name ~= "" then
        return friendReputation.name
    end

    return select(1, GetFactionInfoByID(factionId))
end

---@param reputationReward ReputationPair[]
---@return string @Formatted reputation reward string
function QuestieReputation.GetReputationRewardString(reputationReward)
    local rewardTable = {}

    for _, rewardPair in pairs(reputationReward) do
        local factionId = rewardPair[1]
        local rewardValue = rewardPair[2]
        local factionName = QuestieReputation.GetFactionName(factionId)
        if factionName then
            rewardTable[#rewardTable + 1] = (rewardValue > 0 and "+" or "") .. rewardValue .. " " .. factionName
        end
    end

    return table.concat(rewardTable, " / ")
end

return QuestieReputation
