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

function QuestieLib:GetDifficultyColorPercent(level)

    if level == -1 then
        level = QuestiePlayer:GetPlayerLevel();
    end
    local levelDiff = level - QuestiePlayer:GetPlayerLevel();

    if (levelDiff >= 5) then
        --return "|cFFFF1A1A"..text.."|r"; -- Red
        return 1, 0.102, 0.102
    elseif (levelDiff >= 3) then
        --return "|cFFFF8040"..text.."|r"; -- Orange
        return 1, 0.502, 0.251
    elseif (levelDiff >= -2) then
        --return "|cFFFFFF00"..text.."|r"; -- Yellow
        return 1, 1, 0
    elseif (-levelDiff <= GetQuestGreenRange()) then
        --return "|cFF40C040"..text.."|r"; -- Green
        return 0.251, 0.753, 0.251
    else
        --return "|cFFC0C0C0"..text.."|r"; -- Grey
        return 0.753, 0.753, 0.753
    end
end

function QuestieLib:IsResponseCorrect(questId)
    local count = 0;
    local objectiveList = nil;
    local good = true;
    while (true and count < 50) do
        good = true;
        objectiveList = C_QuestLog.GetQuestObjectives(questId);
        if(objectiveList == nil) then
          good = false;
        else
          for objectiveIndex, objective in pairs(objectiveList) do
              if(objective.text == nil or objective.text == "" or QuestieDB:Levenshtein(": 0/1", objective.text) < 5) then
                  Questie:Debug(DEBUG_SPAM, count, " : Objective text is strange!", "'", objective.text, "'", " distance", QuestieDB:Levenshtein(": 0/1", objective.text));
                  good = false;
                  break;
              end
          end
        end
        if(good) then
            break;
        end
        count = count + 1;
    end
    return good;
end

function QuestieLib:GetQuestObjectives(questId)
    local count = 0;
    local objectiveList = nil;
    while (true and count < 50) do
        local good = true;
        objectiveList = C_QuestLog.GetQuestObjectives(questId);
        if(objectiveList == nil) then
            good = false;
        else
            for objectiveIndex, objective in pairs(objectiveList) do
                if(objective.text == nil or objective.text == "" or QuestieDB:Levenshtein(": 0/1", objective.text) < 5) then
                    Questie:Debug(DEBUG_SPAM, count, " : Objective text is strange!", "'", objective.text, "'", " distance", QuestieDB:Levenshtein(": 0/1", objective.text));
                    good = false;
                    break;
                end
            end
        end
        if(good) then
            break;
        end
        count = count + 1;
    end
    return objectiveList;
end

---@param id integer @The quest ID
---@param name string @The (localized) name of the quest
---@param level integer @The quest level
---@param showLevel integer @Wheather the quest level should be included
---@param isComplete boolean @Wheather the quest is complete
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetColoredQuestName(id, name, level, showLevel, isComplete, blizzLike)
    if showLevel then
        local questType, questTag = GetQuestTagInfo(id)

        if questType and questTag then
            local char = "+"
            if(not blizzLike) then
                char = string.sub(questTag, 1, 1);
            end
            if questType == 1 then
                name = "[" .. level .. "+" .. "] " .. name -- Elite quest
            elseif questType == 81 then
                name = "[" .. level .. char .. "] " .. name -- Dungeon quest
            elseif questType == 62 then
                name = "[" .. level .. char .. "] " .. name -- Raid quest
            elseif questType == 41 then
                name = "[" .. level .. "] " .. name -- Which one? This is just default.
                --name = "[" .. level .. questTag .. "] " .. name -- PvP quest
            elseif questType == 83 then
                name = "[" .. level .. "++" .. "] " .. name -- Legendary quest
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
        if isComplete == -1 then
            name = name .. " (" .. _G['FAILED'] .. ")"
        else
            name = name .. " (" .. _G['COMPLETE'] .. ")"
        end
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

--To try and create a fix for errors regarding items that do not exist in our DB,
--this function tries to prefetch all the items on startup and accept.
function QuestieLib:CacheAllItemNames()
    --[[
        1 name
        2 for quest
        3 dropped by
        [4103]={"Shackle Key",{630},{1559},{}},
    ]]
    local numEntries, numQuests = GetNumQuestLogEntries();
    for index = 1, numEntries do
        local title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if(not isHeader) then
            QuestieLib:CacheItemNames(questId);
        end
    end
end

function QuestieLib:CacheItemNames(questId)
    local quest = QuestieDB:GetQuest(questId);
    for objectiveIndexDB, objectiveDB in pairs(quest.ObjectiveData) do
        if objectiveDB.Type == "item" then
            if not CHANGEME_Questie4_ItemDB[objectiveDB.Id] then
                Questie:Debug(DEBUG_DEVELOP, "Requesting item information for missing itemId:", objectiveDB.Id)
                local item = Item:CreateFromItemID(objectiveDB.Id)
                item:ContinueOnItemLoad(function()
                    local itemName = item:GetItemName();
                    --local itemName = GetItemInfo(objectiveDB.Id)
                    --Create an empty item with the name itself but no drops.
                    CHANGEME_Questie4_ItemDB[objectiveDB.Id] = {itemName,{questId},{},{}};
                    Questie:Debug(DEBUG_DEVELOP, "Created item information for item:", itemName, ":", objectiveDB.Id);
                end)
            end
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

local cachedTitle = nil;
--Move to Questie.lua after QuestieOptions move.
function QuestieLib:GetAddonVersionInfo()  -- todo: better place
    if(not cachedTitle) then
        local name, title, _, _, reason = GetAddOnInfo("QuestieDev-master");
        if(reason == "MISSING") then
            _, title = GetAddOnInfo("Questie");
        end
        cachedTitle = title;
    end
    --%d = digit, %p = punctuation character, %x = hexadecimal digits.
    local major, minor, patch, commit = string.match(cachedTitle, "(%d+)%p(%d+)%p(%d+)");
    return tonumber(major), tonumber(minor), tonumber(patch);
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


function QuestieLib:PlayerInGroup(playerName)
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

function QuestieLib:Count(table) -- according to stack overflow, # and table.getn arent reliable (I've experienced this? not sure whats up)
    local count = 0
    for k, v in pairs(table) do count = count + 1; end
    return count
end

-- Credits to Shagu and pfQuest, why reinvent the wheel.
-- https://gitlab.com/shagu/pfQuest/blob/master/compat/pfUI.lua
local sanitize_cache = {}
function QuestieLib:SanitizePattern(pattern)
  if not sanitize_cache[pattern] then
    local ret = pattern
    -- escape magic characters
    ret = gsub(ret, "([%+%-%*%(%)%?%[%]%^])", "%%%1")
    -- remove capture indexes
    ret = gsub(ret, "%d%$","")
    -- catch all characters
    ret = gsub(ret, "(%%%a)","%(%1+%)")
    -- convert all %s to .+
    ret = gsub(ret, "%%s%+",".+")
    -- set priority to numbers over strings
    ret = gsub(ret, "%(.%+%)%(%%d%+%)","%(.-%)%(%%d%+%)")
    -- cache it
    sanitize_cache[pattern] = ret
  end

  return sanitize_cache[pattern]
end
-- https://github.com/shagu/pfQuest/commit/01177f2eb2926336a1ad741a6082affe78ae7c20
--[[
    function QuestieLib:SanitizePattern(pattern, excludeNumberCapture)
  -- escape brackets
  pattern = gsub(pattern, "%(", "%%(")
  pattern = gsub(pattern, "%)", "%%)")

  -- remove bad capture indexes
  pattern = gsub(pattern, "%d%$s","s") -- %1$s to %s
  pattern = gsub(pattern, "%d%$d","d") -- %1$d to %d
  pattern = gsub(pattern, "%ds","s") -- %2s to %s

  -- add capture to all findings
  pattern = gsub(pattern, "%%s", "(.+)")

  --We might only want to capture the name itself and not numbers.
  if(not excludeNumberCapture) then
    pattern = gsub(pattern, "%%d", "(%%d+)")
  else
    pattern = gsub(pattern, "%%d", "%%d+")
  end

  return pattern
end
]]--