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

function QuestieLib:PrintDifficultyColor(level, text)

    if level == -1 then
        level = QuestiePlayer:GetPlayerLevel();
    end
    local levelDiff = level - QuestiePlayer:GetPlayerLevel();

    if (levelDiff >= 5) then
        return "|cFFFF1A1A"..text.."|r"; -- Red
    elseif (levelDiff >= 3) then
        return "|cFFFF8040"..text.."|r"; -- Orange
    elseif (levelDiff >= -4) then
        return "|cFFFFFF00"..text.."|r"; -- Yellow
    elseif (-levelDiff <= GetQuestGreenRange()) then
        return "|cFF40C040"..text.."|r"; -- Green
    else
        return "|cFFC0C0C0"..text.."|r"; -- Grey
    end
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