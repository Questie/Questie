---@class QuestiePlayer
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
_QuestiePlayer.raceIndex = -1
_QuestiePlayer.classIndex = -1
_QuestiePlayer.className = ""

-- Optimizations
local math_max = math.max;

function QuestiePlayer:Initialize()
    _QuestiePlayer.playerLevel = UnitLevel("player")

    local _, _, raceId = UnitRace("player")
    _QuestiePlayer.raceId = raceId
    raceId = math.pow(2, raceId -1)
    _QuestiePlayer.raceIndex = raceId

    local className, _, classIndex = UnitClass("player")
    classIndex = math.pow(2, classIndex-1)
    _QuestiePlayer.classIndex = classIndex
    _QuestiePlayer.className = className
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
function QuestiePlayer:GetPlayerLevel()
    local level = UnitLevel("player");
    return math_max(_QuestiePlayer.playerLevel, level);
end

---@return number
function QuestiePlayer:GetRaceId()
    return _QuestiePlayer.raceId
end

---@return string
function QuestiePlayer:GetLocalizedClassName()
    return _QuestiePlayer.className
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
    if (not requiredRaces) then
        return true
    end

    return not (requiredRaces ~= 0 and (bit.band(requiredRaces, _QuestiePlayer.raceIndex) == 0))
end

---@return boolean
function QuestiePlayer:HasRequiredClass(requiredClasses)
    if (not requiredClasses) then
        return true
    end

    return not (requiredClasses ~= 0 and (bit.band(requiredClasses, _QuestiePlayer.classIndex) == 0))
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
