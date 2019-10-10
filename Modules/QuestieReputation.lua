QuestieReputation = {...}
local playerReputations = {}

UnitLevel = function() return 60; end

function QuestieReputation:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Update")
    local expandedHeaders = {}

    for i=1, GetNumFactions() do

        local _, _, _, _, _, barValue, _, _, isHeader, isCollapsed, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if isHeader == 1 and isCollapsed == true then
            Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Expanding header")
            ExpandFactionHeader(i)
            table.insert(expandedHeaders, i)
        end

        if isHeader == nil or isHeader == false then
            playerReputations[factionID] = barValue
        end
    end
    -- Collapse all expanded headers again
    for _, v in pairs(expandedHeaders) do
        CollapseFactionHeader(v)
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
