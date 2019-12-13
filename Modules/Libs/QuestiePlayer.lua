---@class QuestiePlayer
local QuestiePlayer = QuestieLoader:CreateModule("QuestiePlayer");
-------------------------
--Import modules.
-------------------------
---@type QuestieDBZone
local QuestieDBZone = QuestieLoader:ImportModule("QuestieDBZone")

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

function QuestiePlayer:GetCurrentZoneId()
    return QuestieDBZone:GetAreaIdByUIMapID(C_Map.GetBestMapForUnit("player"))
end

function QuestiePlayer:GetCurrentContinentId()
    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if currentZoneId == 0 then
        return 1 -- Default to Eastern Kingdom
    end

    local currentContinentId = 1 -- Default to Eastern Kingdom
    for cId, cont in pairs(LangZoneLookup) do
        for id, _ in pairs(cont) do
            if id == currentZoneId then
                currentContinentId = cId
            end
        end
    end
    return currentContinentId
end

function QuestiePlayer:GetPartyMembers()
    local partyMembers = GetHomePartyInfo()
    if partyMembers then
        local party = {}
        for _, v in pairs(partyMembers) do
            local member = {}
            member.Name = v;
            member.Class, _, _ = UnitClass(v);
            member.Level = UnitLevel(v);
            table.insert(party, member);
        end
        return party
    end
    return nil
end

function QuestiePlayer:GetPartyMemberByName(playerName)
    if(UnitInParty("player") or UnitInRaid("player")) then
        local player = {}
        for index=1, 40 do
            local name = nil
            local className, classFilename = nil;
            --This disables raid check for players.
            --if(UnitInRaid("player")) then
            --    name = UnitName("raid"..index);
            --    className, classFilename = UnitClass("raid"..index);
            --end
            if(not name) then
                name = UnitName("party"..index);
                className, classFilename = UnitClass("party"..index);
            end
            if(name == playerName) then
                player.name = playerName;
                player.class = classFilename;
                local rPerc, gPerc, bPerc, argbHex = GetClassColor(classFilename)
                player.r = rPerc;
                player.g = gPerc;
                player.b = bPerc;
                player.colorHex = argbHex;
                return player;
            end
            if(index > 6 and not UnitInRaid("player")) then
                break;
            end
        end
    end
    return nil;
end
