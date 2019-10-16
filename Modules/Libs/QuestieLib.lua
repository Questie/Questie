-- Contains library functions that do not have a logical place.

QuestieLib = {};
local _QuestieLib = {};

--Is set in QuestieLib.lua
QuestieLib.AddonPath = "Interface\\Addons\\QuestieDev-master\\";

-- Math functions are often run A LOT so lets keep these local
local function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
local math_abs = math.abs;
local math_sqrt = math.sqrt;
local math_max = math.max;

--[[
    Red: 5+ level above player
    Orange: 3 - 4 level above player
    Yellow: max 2 level below/above player
    Green: 3 - GetQuestGreenRange() level below player (GetQuestGreenRange() changes on specific player levels)
    Gray: More than GetQuestGreenRange() below player
--]]
function QuestieLib:PrintDifficultyColor(level, text)

    if level == -1 then
        level = QuestiePlayer:GetPlayerLevel();
    end
    local levelDiff = level - QuestiePlayer:GetPlayerLevel();

    if (levelDiff >= 5) then
        return "|cFFFF1A1A"..text.."|r"; -- Red
    elseif (levelDiff >= 3) then
        return "|cFFFF8040"..text.."|r"; -- Orange
    elseif (levelDiff >= -2) then
        return "|cFFFFFF00"..text.."|r"; -- Yellow
    elseif (-levelDiff <= GetQuestGreenRange()) then
        return "|cFF40C040"..text.."|r"; -- Green
    else
        return "|cFFC0C0C0"..text.."|r"; -- Grey
    end
end

---@param id integer @The quest ID
---@param name string @The (localized) name of the quest
---@param level integer @The quest level
---@param showLevel integer @Wheather the quest level should be included
---@param isComplete boolean @Wheather the quest is complete
function QuestieLib:GetColoredQuestName(id, name, level, showLevel, isComplete)
    if showLevel then
        local questType = GetQuestTagInfo(id)
        if questType then
            if questType == 1 then
                name = "[" .. level .. "+] " .. name -- Elite quest
            elseif questType == 81 then
                name = "[" .. level .. "D] " .. name -- Dungeon quest
            elseif questType == 62 then
                name = "[" .. level .. "R] " .. name -- Raid quest
            else
                name = "[" .. level .. "] " .. name -- Some other irrelevant type
            end
        else
            name = "[" .. level .. "] " .. name
        end
    end
    if Questie.db.global.enableTooltipsQuestID then
        name = name .. " (" .. id .. ")"
    end
    if isComplete then
        name  = name .. " " .. QuestieLocale:GetUIString('TOOLTIP_QUEST_COMPLETE')
    end

    return QuestieLib:PrintDifficultyColor(level, name)
end

---@param waypointTable table<integer, Point> @A table containing waypoints {{X, Y}, ...}
---@return integer @X coordinate, 0-100
---@return integer @Y coordinate, 0-100
function QuestieLib:CalculateWaypointMidPoint(waypointTable)
    if(waypointTable) then
        local x = nil;
        local y = nil;
        local distanceList = {}
        local lastPos = nil
        local totalDistance = 0;
        for index, waypoint in pairs(waypointTable) do
            if(lastPos == nil) then
                lastPos = waypoint;
            else
                local distance = QuestieLib:Euclid(lastPos[1], lastPos[2], waypoint[1], waypoint[2]);
                totalDistance = totalDistance + distance;
                distanceList[distance] = index;
            end
        end

        --reset the last pos
        local ranDistance = 0;
        lastPos = nil
        for distance, index in pairs(distanceList) do
            if(lastPos == nil) then
                lastPos = index;
            else
                ranDistance = ranDistance + distance;
                if(ranDistance > totalDistance/2) then
                    local firstMiddle = waypointTable[lastPos];
                    local secondMiddle = waypointTable[index];
                    x = firstMiddle[1];--(firstMiddle[1] + secondMiddle[1])/2
                    y = firstMiddle[2]--(firstMiddle[2] + secondMiddle[2])/2
                    break;
                end
            end
        end
        return x, y;
    end
    return nil, nil;
end

function QuestieLib:ProfileFunction(functionReference, includeSubroutine)
    --Optional var
    if(not includeSubroutine) then includeSubroutine = true; end
    local time, count = GetFunctionCPUUsage(functionReference, includeSubroutine);
    --Questie:Print("[QuestieLib]", "Profiling Avg:", round(time/count, 6));
    return time, count;
end

function QuestieLib:ProfileFunctions()
  for key, value in pairs(QuestieQuest) do
    if(type(value) == "function") then
      local time, count = QuestieLib:ProfileFunction(value, false);
      Questie:Print("[QuestieLib] ", key, "Profiling Avg:", round(time/count, 6));
    end
  end
end

function QuestieLib:Euclid(x, y, i, e)
    local xd = math_abs(x - i);
    local yd = math_abs(y - e);
    return math_sqrt(xd * xd + yd * yd);
end

function QuestieLib:Maxdist(x, y, i, e)
    return math_max(math_abs(x - i), math_abs(y - e))
end

function QuestieLib:Remap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
end

--Move to Questie.lua after QuestieOptions move.
function QuestieLib:GetAddonVersionInfo()  -- todo: better place
    local name, title, _, _, reason = GetAddOnInfo("QuestieDev-master");
    if(reason == "MISSING") then
      _, title = GetAddOnInfo("Questie");
    end
    --%d = digit, %p = punctuation character, %x = hexadecimal digits.
    local major, minor, patch, commit = string.match(title, "(%d+)%p(%d+)%p(%d+)_(%x+)");
    return tonumber(major), tonumber(minor), tonumber(patch), commit;
end

--Search for just Addon\\ at the front since the interface part often gets trimmed
--Code Credit Author(s): Cryect (cryect@gmail.com), Xinhuan and their LibGraph-2.0 
do
	local path = string.match(debugstack(1, 1, 0), "AddOns\\(.+)Modules\\Libs\\QuestieLib.lua")
	if path then
		QuestieLib.AddonPath = "Interface\\AddOns\\"..path
  else
    local major, minor, patch, commit = QuestieLib:GetAddonVersionInfo();
		error("v"..major.."."..minor.."."..patch.."_"..commit.." cannot determine the folder it is located in because the path is too long and got truncated in the debugstack(1, 1, 0) function call")
  end
end