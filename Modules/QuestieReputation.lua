---@class QuestieReputation
local QuestieReputation = QuestieLoader:CreateModule("QuestieReputation")

local playerReputations = {}

function QuestieReputation:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Update")
    ExpandFactionHeader(0) -- Expand all header

    for i=1, GetNumFactions() do
        local _, _, _, _, _, barValue, _, _, isHeader, _, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if isHeader == nil or isHeader == false then
            playerReputations[factionID] = barValue
        end
    end
end

-- This function is just for debugging purpose
-- There is no need to access the playerReputations table somewhere else
function QuestieReputation:GetPlayerReputations()
    return playerReputations
end

function QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep)
    local hasMinRep = true -- the player has reached the min required reputation value
    local hasMaxRep = true -- the player has not reached the max allowed reputation value

    if requiredMinRep ~= nil then
        local minFactionID = requiredMinRep[1]
        local reqMinValue = requiredMinRep[2]

        if playerReputations[minFactionID] ~= nil then
            hasMinRep = playerReputations[minFactionID] >= reqMinValue
        else
            hasMinRep = false
        end
    end
    if requiredMaxRep ~= nil then
        local maxFactionID = requiredMaxRep[1]
        local reqMaxValue = requiredMaxRep[2]

        if playerReputations[maxFactionID] ~= nil then
            hasMaxRep = playerReputations[maxFactionID] < reqMaxValue
        else
            hasMaxRep = false
        end
    end
    return hasMinRep and hasMaxRep
end
