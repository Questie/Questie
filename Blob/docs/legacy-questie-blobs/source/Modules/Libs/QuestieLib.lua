-- Contains library functions that do not have a logical place.
---@class QuestieLib
local QuestieLib = QuestieLoader:CreateModule("QuestieLib")
-------------------------
-- Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

-- Is set in QuestieLib.lua
QuestieLib.AddonPath = "Interface\\Addons\\QuestieDev-master\\"

local math_abs = math.abs
local math_sqrt = math.sqrt
local math_max = math.max
local tinsert = table.insert

--[[
    Red: 5+ level above player
    Orange: 3 - 4 level above player
    Yellow: max 2 level below/above player
    Green: 3 - GetQuestGreenRange() level below player (GetQuestGreenRange() changes on specific player levels)
    Gray: More than GetQuestGreenRange() below player
--]]
function QuestieLib:PrintDifficultyColor(level, text)
    if level == -1 then
        level = QuestiePlayer:GetPlayerLevel()
    end
    local levelDiff = level - QuestiePlayer:GetPlayerLevel()

    if (levelDiff >= 5) then
        return "|cFFFF1A1A" .. text .. "|r" -- Red
    elseif (levelDiff >= 3) then
        return "|cFFFF8040" .. text .. "|r" -- Orange
    elseif (levelDiff >= -2) then
        return "|cFFFFFF00" .. text .. "|r" -- Yellow
    elseif (-levelDiff <= (UnitQuestTrivialLevelRange or GetQuestGreenRange)("player")) then --TBC or Classic function
        return "|cFF40C040" .. text .. "|r" -- Green
    else
        return "|cFFC0C0C0" .. text .. "|r" -- Grey
    end
end

function QuestieLib:GetDifficultyColorPercent(level)

    if level == -1 then level = QuestiePlayer:GetPlayerLevel() end
    local levelDiff = level - QuestiePlayer:GetPlayerLevel()

    if (levelDiff >= 5) then
        -- return "|cFFFF1A1A"..text.."|r"; -- Red
        return 1, 0.102, 0.102
    elseif (levelDiff >= 3) then
        -- return "|cFFFF8040"..text.."|r"; -- Orange
        return 1, 0.502, 0.251
    elseif (levelDiff >= -2) then
        -- return "|cFFFFFF00"..text.."|r"; -- Yellow
        return 1, 1, 0
    elseif (-levelDiff <= GetQuestGreenRange()) then
        -- return "|cFF40C040"..text.."|r"; -- Green
        return 0.251, 0.753, 0.251
    else
        -- return "|cFFC0C0C0"..text.."|r"; -- Grey
        return 0.753, 0.753, 0.753
    end
end

-- 1.12 color logic
local function RGBToHex(r, g, b)
    if r > 255 then r = 255 end
    if g > 255 then g = 255 end
    if b > 255 then b = 255 end
    return string.format("|cFF%02x%02x%02x", r, g, b)
end

local function FloatRGBToHex(r, g, b) return RGBToHex(r * 254, g * 254, b * 254) end

function QuestieLib:GetRGBForObjective(objective)
    if objective.fulfilled ~= nil and objective.Collected == nil then
        objective.Collected = objective.fulfilled
        objective.Needed = objective.required
    end

    if not objective.Collected or type(objective.Collected) ~= "number" then
        return FloatRGBToHex(0.8, 0.8, 0.8)
    end
    local float = objective.Collected / objective.Needed
    local trackerColor = Questie.db.global.trackerColorObjectives

    if not trackerColor or trackerColor == "white" then
        return "|cFFEEEEEE"
    elseif trackerColor == "whiteAndGreen" then
        return
            objective.Collected == objective.Needed and RGBToHex(76, 255, 76) or
                FloatRGBToHex(0.8, 0.8, 0.8)
    elseif trackerColor == "whiteToGreen" then
        return FloatRGBToHex(0.8 - float / 2, 0.8 + float / 3, 0.8 - float / 2)
    else
        if float < .49 then return FloatRGBToHex(1, 0 + float / .5, 0) end
        if float == .50 then return FloatRGBToHex(1, 1, 0) end
        if float > .50 then return FloatRGBToHex(1 - float / 2, 1, 0) end
    end
end

---@param questId QuestId @The quest ID
function QuestieLib:IsResponseCorrect(questId)
    local count = 0
    local objectiveList
    local good = true

    objectiveList = QuestieLib:GetQuestObjectives(questId) --C_QuestLog.GetQuestObjectives(questId)
    if not objectiveList then
        good = false
    else
        for _, objective in pairs(objectiveList) do
            if (objective.text == nil or objective.text == "" or
                --QuestieLib:Levenshtein(": 0/1", objective.text) < 5) then
                objective.text:sub(1, 1) == " ") then
                --print(questId, objective.text, objective.type, objective.finished, objective.numFulfilled, objective.numRequired)
                Questie:Debug(DEBUG_SPAM, count,
                                " : Objective text is strange!", "'",
                                objective.text, "'", " distance",
                                QuestieLib:Levenshtein(": 0/1", objective.text))
                good = false
                --print("ObjectiveText is strange:", questId)
                break
            end
        end
    end

    return good
end

--Cache the objectiveText
local objectiveText = {}
---@param questId QuestId @The quest ID
---@return QuestObjectives
---@return boolean @Was the response correct?
function QuestieLib:GetQuestObjectives(questId)
    if(objectiveText[questId] == nil) then
        objectiveText[questId] = {}
    end

    local objectiveList
    local good = true



    objectiveList = C_QuestLog.GetQuestObjectives(questId)
    if not objectiveList then
        good = false
    else
        for index, objective in pairs(objectiveList) do
            if (objective.text == nil or objective.text == "" or
            objective.text:sub(1, 1) == " ") then --QuestieLib:Levenshtein(": 0/1", objective.text) < 5) then
                --As a fallback we can use the cache to try and return the correct information
                --Blizzard always returns the correct numFulfilled and numRequired!
                if(objectiveText[questId][index]) then
                    --We use gsub here to update the string we had to the correct values, will work even if it can't find anything
                    --And just return the old value in that case
                    print("Using cache for name! BeforeGSUB", objective.text)
                    objective.text = objectiveText[questId][index]:gsub("%d+/%d+", objective.numFulfilled.."/"..objective.numRequired)
                    print("Using cache for name! AfterGSUB", objective.text)
                else
                    --print(questId, objective.text, objective.type, objective.finished, objective.numFulfilled, objective.numRequired)
                    print("Incorrect response", objective.text)
                    Questie:Debug(DEBUG_SPAM,
                                " : Objective text is strange!", "'",
                                objective.text, "'", " distance",
                                QuestieLib:Levenshtein(": 0/1", objective.text))
                    good = false
                end
            else
                --We set it every time because if gsub does not work we always want the newest version atleast
                objectiveText[questId][index] = objective.text
            end
        end
    end
    Questie:Debug(DEBUG_SPAM, "[QuestieLib:GetQuestObjectives]: Loaded objective(s) for quest:", questId)
    return objectiveList, good
end

---@param id QuestId @The quest ID
---@param name string @The (localized) name of the quest
---@param level number @The quest level
---@param showLevel number @ Whether the quest level should be included
---@param showState boolean @ Whether to show (Complete/Failed)
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetColoredQuestName(id, name, level, showLevel, showState, blizzLike)
    if showLevel then
        name = QuestieLib:GetQuestString(id, name, level, blizzLike)
    end
    if Questie.db.global.enableTooltipsQuestID then
        name = name .. " (" .. id .. ")"
    end

    if showState then
        local isComplete = QuestieDB:IsComplete(id)

        if isComplete == -1 then
            name = name .. " (" .. _G['FAILED'] .. ")"
        elseif isComplete == 1 then
            name = name .. " (" .. _G['COMPLETE'] .. ")"
        end
    end

    if (not Questie.db.global.collapseCompletedQuests and (Questie.db.char.collapsedQuests and Questie.db.char.collapsedQuests[id] == nil)) then
        return QuestieLib:PrintDifficultyColor(level, name)
    end

    return QuestieLib:PrintDifficultyColor(level, name)
end

function QuestieLib:GetRandomColor(randomSeed)
    QuestieLib:MathRandomSeed(randomSeed)
    return {
        0.45 + QuestieLib:MathRandom() / 2,
        0.45 + QuestieLib:MathRandom() / 2,
        0.45 + QuestieLib:MathRandom() / 2
    }
end

---@param id QuestId @The quest ID
---@param name string @The (localized) name of the quest
---@param level number @The quest level
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetQuestString(id, name, level, blizzLike)
    local questType, questTag = QuestieDB:GetQuestTagInfo(id)

    if questType and questTag then
        local char = "+"
        if (not blizzLike) then
            char = string.sub(questTag, 1, 1)
        end

        local langCode = QuestieLocale:GetUILocale() -- the string.sub above doesn't work for multi byte characters in Chinese
        if questType == 1 then
            name = "[" .. level .. "+" .. "] " .. name -- Elite quest
        elseif questType == 81 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "D"
            end
            name = "[" .. level .. char .. "] " .. name -- Dungeon quest
        elseif questType == 62 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "R"
            end
            name = "[" .. level .. char .. "] " .. name -- Raid quest
        elseif questType == 41 then
            name = "[" .. level .. "] " .. name -- Which one? This is just default.
            -- name = "[" .. level .. questTag .. "] " .. name -- PvP quest
        elseif questType == 83 then
            name = "[" .. level .. "++" .. "] " .. name -- Legendary quest
        else
            name = "[" .. level .. "] " .. name -- Some other irrelevant type
        end
    else
        name = "[" .. level .. "] " .. name
    end

    return name
end

---@param id QuestId @The quest ID
---@param name string @The (localized) name of the quest
---@param level number @The quest level
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetLevelString(id, name, level, blizzLike)
    local questType, questTag = QuestieDB:GetQuestTagInfo(id)

    if questType and questTag then
        local char = "+"
        if (not blizzLike) then
            char = string.sub(questTag, 1, 1)
        end

        local langCode = QuestieLocale:GetUILocale() -- the string.sub above doesn't work for multi byte characters in Chinese
        if questType == 1 then
            level = "[" .. level .. "+" .. "] " -- Elite quest
        elseif questType == 81 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "D"
            end
            level = "[" .. level .. char .. "] " -- Dungeon quest
        elseif questType == 62 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "R"
            end
            level = "[" .. level .. char .. "] " -- Raid quest
        elseif questType == 41 then
            level = "[" .. level .. "] " -- Which one? This is just default.
            -- name = "[" .. level .. questTag .. "] " .. name -- PvP quest
        elseif questType == 83 then
            level = "[" .. level .. "++" .. "] " -- Legendary quest
        else
            level = "[" .. level .. "] " -- Some other irrelevant type
        end
    else
        level = "[" .. level .. "] "
    end

    return level
end

function QuestieLib:ProfileFunction(functionReference, includeSubroutine)
    -- Optional var
    if (not includeSubroutine) then includeSubroutine = true end
    local now, count = GetFunctionCPUUsage(functionReference, includeSubroutine)
    -- Questie:Print("[QuestieLib]", "Profiling Avg:", round(time/count, 6));
    return now, count
end

-- To try and create a fix for errors regarding items that do not exist in our DB,
-- this function tries to prefetch all the items on startup and accept.
function QuestieLib:CacheAllItemNames()
    --[[
        1 name
        2 for quest
        3 dropped by
        [4103]={"Shackle Key",{630},{1559},{}},
    ]]

    local numEntries;
    if(C_QuestLog.GetNumQuestLogEntries) then
        numEntries = C_QuestLog.GetNumQuestLogEntries()
        for index = 1, numEntries do
            local questId = C_QuestLog.GetQuestIDForLogIndex(index)
            if (questId) then QuestieLib:CacheItemNames(questId) end
        end
    else
        numEntries = GetNumQuestLogEntries()
        for index = 1, numEntries do
            local _, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(index)
            if (not isHeader) then QuestieLib:CacheItemNames(questId) end
        end
    end
end

function QuestieLib:CacheItemNames(questId)
    local quest = QuestieDB:GetQuest(questId)
    if (quest and quest.ObjectiveData) then
        for objectiveIndexDB, objectiveDB in pairs(quest.ObjectiveData) do
            if objectiveDB.Type == "item" then
                if not ((QuestieDB.ItemPointers or QuestieDB.itemData)[objectiveDB.Id]) then
                    Questie:Debug(DEBUG_DEVELOP,
                                  "Requesting item information for missing itemId:",
                                  objectiveDB.Id)
                    local item = Item:CreateFromItemID(objectiveDB.Id)
                    item:ContinueOnItemLoad(
                        function()
                            local itemName = item:GetItemName()
                            if not QuestieDB.itemDataOverrides[objectiveDB.Id] then
                                QuestieDB.itemDataOverrides[objectiveDB.Id] =  {itemName, {questId}, {}, {}}
                            else
                                QuestieDB.itemDataOverrides[objectiveDB.Id][1] = itemName
                            end
                            Questie:Debug(DEBUG_DEVELOP,
                                          "Created item information for item:",
                                          itemName, ":", objectiveDB.Id)
                        end)
                end
            end
        end
    end
end

function QuestieLib:Euclid(x, y, i, e)
    local xd = math_abs(x - i)
    local yd = math_abs(y - e)
    return math_sqrt(xd * xd + yd * yd)
end

function QuestieLib:Maxdist(x, y, i, e)
    return math_max(math_abs(x - i), math_abs(y - e))
end

function QuestieLib:Remap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function QuestieLib:GetTableSize(table)
    local count = 0
    if table then
        for _,_ in pairs(table) do
            count = count +1
        end
    end
    return count
end

local cachedTitle = nil
local cachedVersion = nil
-- Move to Questie.lua after QuestieOptions move.
function QuestieLib:GetAddonVersionInfo()
    if (not cachedTitle) or (not cachedVersion) then
        local name, title, _, _, reason = GetAddOnInfo("QuestieDev-master")
        if (reason == "MISSING") then name, title = GetAddOnInfo("Questie") end
        cachedTitle = title
        cachedVersion = GetAddOnMetadata(name, "Version")
    end

    -- %d = digit, %p = punctuation character, %x = hexadecimal digits.
    local major, minor, patch = string.match(cachedVersion, "(%d+)%p(%d+)%p(%d+)")

    local buildType = nil

    if string.match(cachedTitle, "ALPHA") then
        buildType = "ALPHA"
    elseif string.match(cachedTitle, "BETA") then
        buildType = "BETA"
    end

    return tonumber(major), tonumber(minor), tonumber(patch), tostring(buildType)
end

function QuestieLib:GetAddonVersionString()
    local major, minor, patch, buildType = QuestieLib:GetAddonVersionInfo()

    if buildType and buildType ~= "nil" then
        buildType = " - " .. buildType
    else
        buildType = ""
    end

    return "v" .. tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch) .. buildType
end

-- Search for just Addon\\ at the front since the interface part often gets trimmed
-- Code Credit Author(s): Cryect (cryect@gmail.com), Xinhuan and their LibGraph-2.0
do
    local path = string.match(debugstack(1, 1, 0),
                              "AddOns\\(.+)Modules\\Libs\\QuestieLib.lua")
    if path then
        QuestieLib.AddonPath = "Interface\\AddOns\\" .. path
    else
        local major, minor, patch, commit = QuestieLib:GetAddonVersionInfo()
        error("v" .. major .. "." .. minor .. "." .. patch .. "_" .. commit ..
                  " cannot determine the folder it is located in because the path is too long and got truncated in the debugstack(1, 1, 0) function call")
    end
end

function QuestieLib:Count(table) -- according to stack overflow, # and table.getn arent reliable (I've experienced this? not sure whats up)
    local count = 0
    for k, v in pairs(table) do count = count + 1 end
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
        ret = gsub(ret, "%d%$", "")
        -- catch all characters
        ret = gsub(ret, "(%%%a)", "%(%1+%)")
        -- convert all %s to .+
        ret = gsub(ret, "%%s%+", ".+")
        -- set priority to numbers over strings
        ret = gsub(ret, "%(.%+%)%(%%d%+%)", "%(.-%)%(%%d%+%)")
        -- cache it
        sanitize_cache[pattern] = ret
    end

    return sanitize_cache[pattern]
end

function QuestieLib:SortQuestsByLevel(quests)
    local sortedQuestsByLevel = {}

    local function compareTablesByIndex(a, b)
        return a[1] < b[1]
    end

    for _, q in pairs(quests) do
        tinsert(sortedQuestsByLevel, {q.questLevel, q})
    end
    table.sort(sortedQuestsByLevel, compareTablesByIndex)

    return sortedQuestsByLevel
end

function QuestieLib:SortQuestIDsByLevel(quests)
    local sortedQuestsByLevel = {}

    local function compareTablesByIndex(a, b)
        return a[1] < b[1]
    end

    for q in pairs(quests) do
        tinsert(sortedQuestsByLevel, {QuestieDB.QueryQuestSingle(q, "questLevel") or 0, q})
    end
    table.sort(sortedQuestsByLevel, compareTablesByIndex)

    return sortedQuestsByLevel
end

---------------------------------------------------------------------------------------------------
-- Returns the Levenshtein distance between the two given strings
-- credit to https://gist.github.com/Badgerati/3261142
function QuestieLib:Levenshtein(str1, str2)
    local len1 = string.len(str1)
    local len2 = string.len(str2)
    local matrix = {}
    local cost = 0
    -- quick cut-offs to save time
    if (len1 == 0) then
        return len2
    elseif (len2 == 0) then
        return len1
    elseif (str1 == str2) then
        return 0
    end
    -- initialise the base matrix values
    for i = 0, len1, 1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, len2, 1 do
        matrix[0][j] = j
    end
    -- actual Levenshtein algorithm
    for i = 1, len1, 1 do
        for j = 1, len2, 1 do
            if (string.byte(str1, i) == string.byte(str2, j)) then
                cost = 0
            else
                cost = 1
            end
            matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1,
                                    matrix[i - 1][j - 1] + cost)
        end
    end
    -- return the last value - this is the Levenshtein distance
    return matrix[len1][len2]
end

local randomSeed = 0
function QuestieLib:MathRandomSeed(seed)
    randomSeed = seed
end

function QuestieLib:MathRandom(low_or_high_arg, high_arg)
    local low = nil
    local high = nil
    if low_or_high_arg ~= nil then
        if high_arg ~= nil then
            low = low_or_high_arg
            high = high_arg
        else
            low = 1
            high = low_or_high_arg
        end
    end

    randomSeed = (randomSeed * 214013 + 2531011) % 2^32
    local rand = (math.floor(randomSeed / 2^16) % 2^15) / 0x7fff
    if high == nil then
        return rand
    end
    return low + math.floor(rand * high)
end

function QuestieLib:UnpackBinary(val)
    local ret = {}
    for q=0, 16 do
        if bit.band(bit.rshift(val,q), 1) == 1 then
            tinsert(ret, true)
        else
            tinsert(ret, false)
        end
    end
    return ret
end

local colorWheel = {
    {80,  113, 255},  --Blizzard Polygon-blue --Alpha of 128
    --{123,  146, 255},  --Blizzard Polygon-blue-2 --Alpha of 61
    {128, 120, 217},  --Medium Purple
    {149, 229, 14},   --Inch Worm
    {117, 218, 200},  --Downy
    {255, 144, 160},  --Salmon Pink
    --{149, 159, 112},  --Avocado, Bad? Fix it
    {0,   166, 152},  --Persian Green
    {0,   250, 140},  --Spring Green
    {181, 28,  122},  --Medium Violet Red     --ORG Dark Purple {119, 18,  79}
    {149, 55,  255},  --Light Slate Blue
    {185, 94,  0},    --Alloy Orange
    {218, 55,  147},  --Deep Cerise
    {223, 224, 145},  --Primrose
    {255, 167, 0},    --Orange
    {208, 182, 255},  --Mauve
    {0,   65,  151},  --Smalt
    {255, 64,  255},  --Pink Flamingo
    {254, 251, 0},    --Yellow
    {255, 255, 255},  --White
    {41,  167, 0},    --Slimy Green
    {0,   169, 255},  --Deep Sky Blue
    {0,   150,  0},    --Vine Green --G67 default
    {1,   74,  255},  --Navy Blue
    {0,   249, 0},    --Lime
    {0,   252, 255},  --Aqua
    {255, 38,  0},    --Scarlet
}
-- structure
--[[
questColor[questId][objectiveIndex] = {r,g,b}
]]--
local lastIndex = 1;
function QuestieLib:GetColor(questId, objectiveIndex)
    if(not Questie.db.char.questColor) then
        Questie.db.char.questColor = {}
    end
    local questColorRef = Questie.db.char.questColor
    if(questColorRef[questId] and questColorRef[questId][objectiveIndex]) then
        local rColor = colorWheel[questColorRef[questId][objectiveIndex].colorIndex]
        return {rColor[1]/255, rColor[2]/255, rColor[3]/255}
    else
        local colorIndex = lastIndex;
        if(not questColorRef[questId]) then
            questColorRef[questId] = {}
        end
        questColorRef[questId][objectiveIndex] = {colorIndex=colorIndex};
        lastIndex = lastIndex + 1;
        if(lastIndex > #colorWheel) then
            lastIndex = 1;
        end
        local rColor = colorWheel[questColorRef[questId][objectiveIndex].colorIndex]
        return {rColor[1]/255, rColor[2]/255, rColor[3]/255}

    end
end


--Part of the GameTooltipWrapDescription function
local objectiveFontString = UIParent:CreateFontString("questieObjectiveTextString", "ARTWORK", "QuestFont")
objectiveFontString:SetWidth(_G["QuestLogObjectivesText"]:GetWidth() or 275) --QuestLogObjectivesText default width = 275
objectiveFontString:SetHeight(0);
objectiveFontString:SetPoint("LEFT");
objectiveFontString:SetJustifyH("LEFT");
objectiveFontString:SetWordWrap(true)
objectiveFontString:SetVertexColor(1,1,1, 0)--Set opacity to 0, even if it is shown it should be invisible
local font, size = _G["QuestLogObjectivesText"]:GetFont()
--Chinese? "Fonts\\ARKai_T.ttf"
objectiveFontString:SetFont(font, size);
objectiveFontString:Hide()

---Emulates the wrapping of a quest description
---@param line string @The line to wrap
---@param combineTrailing boolean @If the last line is only one word, combine it with previous? TRUE=COMBINE, FALSE=NOT COMBINE, default: true
---@param splitOnDot boolean @Should we add a linebreak if a dot appears thats not at the end of a line TRUE=NEW ROW, FALSE=NO NEW ROW, default: true
---@param desiredWidth number @Set the desired width to wrap, default: 275
---@return table[] @A table of wrapped lines
function QuestieLib:TextWrap(line, combineTrailing, splitOnDot, desiredWidth)
    if(objectiveFontString:IsVisible()) then Questie:Error("TextWrap already running... strange, look into pooling the FontString ugh") end

    --Set Defaults
    combineTrailing = combineTrailing or true
    splitOnDot = splitOnDot or true
    --We show the fontstring and set the text to start the process
    --We have to show it or else the functions won't work... But we set the opacity to 0 on creation
    objectiveFontString:SetWidth(desiredWidth or _G["QuestLogObjectivesText"]:GetWidth() or 275) --QuestLogObjectivesText default width = 275
    objectiveFontString:Show()
    --print(line)
    --Make a linebreak on each "dot" character if there is a space after (don't want it on end of line)
    line = string.gsub(line, "%. ", "%.%\n")

    --print(line)

    objectiveFontString:SetText(line)
    --Is the line wrapped?
    if(objectiveFontString:GetUnboundedStringWidth() > objectiveFontString:GetWrappedWidth()) then
        local lines = {}
        local startIndex = 1
        local endIndex = 2 --We should be able to start at a later index...
        --This function returns a list of size information per row, so we use this to calculate number of rows
        local numberOfRows = #objectiveFontString:CalculateScreenAreaFromCharacterSpan(startIndex, strlen(line))
        --print("lineLen", strlen(line))
        for row = 1, numberOfRows do
            local lastSpaceIndex
            local dotIndex
            local indexes
            --print("Row: ", row)
            --We use the previous way to get number of rows to loop through characterindex until we get 2 rows
            repeat
                indexes = objectiveFontString:CalculateScreenAreaFromCharacterSpan(startIndex, endIndex)
                --Last space of the line to be used to break a new row
                if(string.sub(line, endIndex, endIndex) == " ") then
                    lastSpaceIndex = endIndex
                --Track the dot at the end of a line
                elseif(string.sub(line, endIndex, endIndex) == "." and endIndex ~= strlen(line) and splitOnDot) then
                    dotIndex = endIndex
                end
                endIndex = endIndex + 1
                --If we are at the end of characters break and set endIndex to strlen
                if(endIndex > strlen(line)) then
                    endIndex = strlen(line)
                    lastSpaceIndex = endIndex
                    break
                end
            until (#indexes > 1) --Until more than one row

            --Get the line we calculated
            --First to Dot, then space and lastly endIndex(chinese)
            local newLine = string.sub(line, startIndex, dotIndex or lastSpaceIndex or endIndex)

            --This combines a trailing word to the previous line if it is the only word of the line
            --We check lastSpaceIndex here because the logic will be faulty (chinese client)
            if(row == numberOfRows-1 and combineTrailing and lastSpaceIndex) then
                --Get the last line, in it's full
                local lastLine = string.sub(line, endIndex - 2, strlen(line))

                --Does the line not contain any space we combine it into the previous line
                if(not string.find(lastLine, " ")) then
                    newLine = string.sub(line, startIndex, strlen(line))
                    --print("NL1", newLine)
                    table.insert(lines, newLine)
                    --Break the for loop on last line, no more running required
                    break
                end
            end

            --Change the startIndex to be the new line, and add the line to the lines list
            startIndex = endIndex - 2
            endIndex = endIndex
            --print("NL2", newLine)
            table.insert(lines, newLine)
        end
        --Hide the fontstring
        objectiveFontString:Hide()
        return lines
    else
        --Line was not wrapped, return the string as is.
        --Hide the fontstring
        objectiveFontString:Hide()
        return {line}
    end
end