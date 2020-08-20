---@class QuestieReputation
local QuestieReputation = QuestieLoader:CreateModule("QuestieReputation")

local playerReputations = {}

local _ReachedNewStanding, _WinterSaberChanged

--- Updates all factions a player already discovered and checks if any of these
--- reached a new reputation level
---@param isInit boolean @
function QuestieReputation:Update(isInit)
    Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Update")
    ExpandFactionHeader(0) -- Expand all header

    local factionChanged = false

    for i=1, GetNumFactions() do
        local name, _, standingId, _, _, barValue, _, _, isHeader, _, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if isHeader == nil or isHeader == false then
            local previousValues = playerReputations[factionID]
            playerReputations[factionID] = {standingId, barValue}

            if (not isInit) and (
                    _ReachedNewStanding(previousValues, standingId)
                    or _WinterSaberChanged(factionID, previousValues, barValue)) then
                Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Update -", "faction \"" .. name .. "\" (" .. factionID .. ") changed")
                factionChanged = true
            end
        end
    end

    return factionChanged
end

---@return boolean
_ReachedNewStanding = function(previousValues, standingId)
    return previousValues ~= nil and previousValues[1] ~= standingId
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

--- Checkout https://github.com/AeroScripts/QuestieDev/wiki/Corrections#reputation-levels for more information
function QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep)
    local hasMinRep = true -- the player has reached the min required reputation value
    local hasMaxRep = true -- the player has not reached the max allowed reputation value

    if requiredMinRep ~= nil then
        local minFactionID = requiredMinRep[1]
        local reqMinValue = requiredMinRep[2]

        if playerReputations[minFactionID] ~= nil then
            hasMinRep = playerReputations[minFactionID][2] >= reqMinValue
        else
            hasMinRep = false
        end
    end
    if requiredMaxRep ~= nil then
        local maxFactionID = requiredMaxRep[1]
        local reqMaxValue = requiredMaxRep[2]

        if playerReputations[maxFactionID] ~= nil then
            hasMaxRep = playerReputations[maxFactionID][2] < reqMaxValue
        else
            hasMaxRep = false
        end
    end
    return hasMinRep and hasMaxRep
end
