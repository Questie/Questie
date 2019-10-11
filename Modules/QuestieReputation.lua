QuestieReputation = {...}
local playerReputations = {}

function QuestieReputation:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Update")
    ExpandFactionHeader(0) -- Expand all header

    for i=1, GetNumFactions() do
        local _, _, _, _, _, barValue, _, _, isHeader, isCollapsed, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if isHeader == nil or isHeader == false then
            playerReputations[factionID] = barValue
        end
    end
end

-- This function is just for debugging purpose
-- These is no need to access the playerReputations table somewhere else
function QuestieReputation:GetPlayerReputations()
    return playerReputations
end

function QuestieProfessions:HasReputation(requiredMinRep)
    if requiredMinRep ~= nil then
        local factionID = requiredMinRep[1]
        local reqValue = requiredMinRep[2]

        if playerReputations[factionID] ~= nil then
            return playerReputations[factionID] >= reqValue
        end
        return false
    end
    return true
end
