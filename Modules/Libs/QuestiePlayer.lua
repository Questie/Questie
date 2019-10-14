QuestiePlayer = {...};
local _QuestiePlayer = {...};

QuestiePlayer.currentQuestlog = {} --Gets populated by QuestieQuest:GetAllQuestIds(), this is either an object to the quest in question, or the ID if the object doesn't exist.
_QuestiePlayer.playerLevel = -1

-- Optimizations
local math_max = math.max;

function QuestiePlayer:Initialize()
    _QuestiePlayer.playerLevel = UnitLevel("player")
end

--Always compare to the UnitLevel parameter, returning the highest.
function QuestiePlayer:SetPlayerLevel(level)
    local localLevel = UnitLevel("player");
    _QuestiePlayer.playerLevel = math_max(localLevel, level);
end

-- Gets the highest playerlevel available, most of the time playerLevel should be the most correct one
-- doing UnitLevel for completeness.
function QuestiePlayer:GetPlayerLevel()
    local level = UnitLevel("player");
    return math_max(_QuestiePlayer.playerLevel, level);
end


function QuestiePlayer:GetGroupType()
    if(UnitInRaid("player")) then
        return "raid";
    elseif(UnitInParty("player")) then
        return "party";
    else
        return nil;
    end
end