---@class QuestiePlayer
---@field numberOfGroupMembers number ---The number of players currently in the group
local QuestiePlayer = QuestieLoader:CreateModule("QuestiePlayer");
local _QuestiePlayer = QuestiePlayer.private
-------------------------
--Import modules.
-------------------------
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestiePlayer.currentQuestlog = {} --Gets populated by QuestieQuest:GetAllQuestIds(), this is either an object to the quest in question, or the ID if the object doesn't exist.
_QuestiePlayer.playerLevel = -1
local playerRaceId = -1
local playerRaceFlag = 255 -- dummy default value to always return race not matching, corrected in init
local playerRaceFlagX2 = 1 -- dummy default value to always return race not matching, corrected in init
local playerClassName = ""
local playerClassFlag = 255 -- dummy default value to always return class not matching, corrected in init
local playerClassFlagX2 = 1 -- dummy default value to always return class not matching, corrected in init

-- Optimizations
local math_max = math.max;

QuestiePlayer.numberOfGroupMembers = 0

function QuestiePlayer:Initialize()
    _QuestiePlayer.playerLevel = UnitLevel("player")

    playerRaceId = select(3, UnitRace("player"))
    playerRaceFlag = 2 ^ (playerRaceId - 1)
    playerRaceFlagX2 = 2 * playerRaceFlag

    playerClassName = select(1, UnitClass("player"))
    local classId = select(3, UnitClass("player"))
    playerClassFlag = 2 ^ (classId - 1)
    playerClassFlagX2 = 2 * playerClassFlag
end

--Always compare to the UnitLevel parameter, returning the highest.
---@return number
function QuestiePlayer:SetPlayerLevel(level)
    local localLevel = UnitLevel("player");
    _QuestiePlayer.playerLevel = math_max(localLevel, level);
end

-- Gets the highest playerlevel available, most of the time playerLevel should be the most correct one
-- doing UnitLevel for completeness.
---@return number
function QuestiePlayer.GetPlayerLevel()
    local level = UnitLevel("player");
    return math_max(_QuestiePlayer.playerLevel, level);
end

---@return number
function QuestiePlayer:GetRaceId()
    return playerRaceId
end

---@return string
function QuestiePlayer:GetLocalizedClassName()
    return playerClassName
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

---@return boolean
function QuestiePlayer:HasRequiredRace(requiredRaces)
    -- test a bit flag: (value % (2*flag) >= flag)
    return (not requiredRaces) or (requiredRaces == 0) or ((requiredRaces % playerRaceFlagX2) >= playerRaceFlag)
end

---@return boolean
function QuestiePlayer:HasRequiredClass(requiredClasses)
    -- test a bit flag: (value % (2*flag) >= flag)
    return (not requiredClasses) or (requiredClasses == 0) or ((requiredClasses % playerClassFlagX2) >= playerClassFlag)
end

function QuestiePlayer:GetCurrentZoneId()
    return ZoneDB:GetAreaIdByUiMapId(C_Map.GetBestMapForUnit("player"))
end

---@return number
function QuestiePlayer:GetCurrentContinentId()
    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if (not currentZoneId) or currentZoneId == 0 then
        return 1 -- Default to Eastern Kingdom
    end

    local currentContinentId = 1 -- Default to Eastern Kingdom
    for cId, cont in pairs(l10n.zoneLookup) do
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
            local class, _, _ = UnitClass(v)
            member.Class = class
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
            local name = UnitName("party"..index);
            local _, classFilename = UnitClass("party"..index);
            if name == playerName then
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

function QuestiePlayer:GetPartyMemberList()
    local members = {}
    if(UnitInParty("player") or UnitInRaid("player")) then
        for index=1, 40 do
            local name = UnitName("party"..index)
            if name then
                members[name] = true
            end
            if(index > 6 and not UnitInRaid("player")) then
                break
            end
        end
    end
    return members
end
