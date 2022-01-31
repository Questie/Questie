---@class QuestieLib
local QuestieLib = QuestieLoader:CreateModule("QuestieLib")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieLib.AddonPath = "Interface\\Addons\\Questie\\"

local math_abs = math.abs
local math_sqrt = math.sqrt
local math_max = math.max
local tinsert = table.insert
local stringSub = string.sub

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
    elseif (-levelDiff <= GetQuestGreenRange("player")) then
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
    elseif (-levelDiff <= GetQuestGreenRange("player")) then
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

---@param questId number @The quest ID
---@return boolean
function QuestieLib:IsResponseCorrect(questId)
    local objectiveList = C_QuestLog.GetQuestObjectives(questId)

    if not objectiveList then
        return false
    end

    for key, objective in pairs(objectiveList) do
        local text, objectiveType = objective.text, objective.type
        if (not objectiveType) or objectiveType == ""
        or (not text) or stringSub(text, 1, 1) == " " then
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieLib:GetQuestObjectives] Objective not cached yet. questId=", questId, "objective=", key, "type=", objectiveType, "text=", text)
            return false
        end
    end

    return true
end

---@param questId number @The quest ID
---@return table
function QuestieLib:GetQuestObjectives(questId)
    local objectiveList = C_QuestLog.GetQuestObjectives(questId)

    for key, objective in pairs(objectiveList or {}) do
        local text = objective.text
        if (not text) or stringSub(text, 1, 1) == " " then
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieLib:GetQuestObjectives] Objective not cached yet. questId=", questId, "objective=", key, "text=", text)
            break -- old code didn't do anything smart with "strange objective", so not doing either
        end
    end

    --Questie:Debug(Questie.DEBUG_SPAM, "[QuestieLib:GetQuestObjectives]: Loaded objective(s) for quest:", questId)
    return objectiveList
end

---@param questId number
---@param showLevel number @ Whether the quest level should be included
---@param showState boolean @ Whether to show (Complete/Failed)
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetColoredQuestName(questId, showLevel, showState, blizzLike)
    local name = QuestieDB.QueryQuestSingle(questId, "name");
    local level, _ = QuestieLib:GetTbcLevel(questId);

    if showLevel then
        name = QuestieLib:GetQuestString(questId, name, level, blizzLike)
    end
    if Questie.db.global.enableTooltipsQuestID then
        name = name .. " (" .. questId .. ")"
    end

    if showState then
        local isComplete = QuestieDB:IsComplete(questId)

        if isComplete == -1 then
            name = name .. " (" .. l10n("Failed") .. ")"
        elseif isComplete == 1 then
            name = name .. " (" .. l10n("Complete") .. ")"
        end
    end

    if (not Questie.db.global.collapseCompletedQuests and (Questie.db.char.collapsedQuests and Questie.db.char.collapsedQuests[questId] == nil)) then
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

---@param questId number
---@param name string @The (localized) name of the quest
---@param level number @The quest level
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetQuestString(questId, name, level, blizzLike)
    local questType, questTag = QuestieDB:GetQuestTagInfo(questId)

    if questType and questTag then
        local char = "+"
        if (not blizzLike) then
            char = string.sub(questTag, 1, 1)
        end

        local langCode = l10n:GetUILocale() -- the string.sub above doesn't work for multi byte characters in Chinese
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

--- There are quests in TBC which have a quest level of -1. This indicates that the quest level is the
--- same as the player level. This function should be used whenever accessing the quest or required level.
---@param questId number
---@return table<number, number> questLevel and requiredLevel
function QuestieLib:GetTbcLevel(questId)
    local questLevel, requiredLevel = unpack(QuestieDB.QueryQuest(questId, "questLevel", "requiredLevel"))
    if (questLevel == -1) then
        local playerLevel = QuestiePlayer:GetPlayerLevel();
        if (requiredLevel > playerLevel) then
            questLevel = requiredLevel;
        else
            questLevel = playerLevel;
            -- We also set the requiredLevel to the player level so the quest is not hidden without "show low level quests"
            requiredLevel = playerLevel;
        end
    end
    return questLevel, requiredLevel;
end

---@param questId number
---@param level number @The quest level
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetLevelString(questId, _, level, blizzLike)
    local questType, questTag = QuestieDB:GetQuestTagInfo(questId)

    if questType and questTag then
        local char = "+"
        if (not blizzLike) then
            char = string.sub(questTag, 1, 1)
        end

        local langCode = l10n:GetUILocale() -- the string.sub above doesn't work for multi byte characters in Chinese
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

function QuestieLib:GetRaceString(raceMask)
    if not raceMask then
        return ""
    end

    if (raceMask == 0) or (raceMask == QuestieDB.raceKeys.ALL) then
        return l10n("None")
    elseif raceMask == QuestieDB.raceKeys.ALL_ALLIANCE then
        return l10n("Alliance")
    elseif raceMask == QuestieDB.raceKeys.ALL_HORDE then
        return l10n("Horde")
    else
        local raceString = ""
        local raceTable = QuestieLib:UnpackBinary(raceMask)
        local stringTable = {
            l10n('Human'),
            l10n('Orc'),
            l10n('Dwarf'),
            l10n('Nightelf'),
            l10n('Undead'),
            l10n('Tauren'),
            l10n('Gnome'),
            l10n('Troll'),
            l10n('Goblin'),
            l10n('Blood Elf'),
            l10n('Draenei')
        }
        local firstRun = true
        for k, v in pairs(raceTable) do
            if v then
                if firstRun then
                    firstRun = false
                else
                    raceString = raceString .. ", "
                end
                raceString = raceString .. stringTable[k]
            end
        end
        return raceString
    end
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
    local numEntries, _ = GetNumQuestLogEntries()
    for index = 1, numEntries do
        local _, _, _, isHeader, _, _, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif (not isHeader) then QuestieLib:CacheItemNames(questId) end
    end
end

function QuestieLib:CacheItemNames(questId)
    local quest = QuestieDB:GetQuest(questId)
    if (quest and quest.ObjectiveData) then
        for _, objectiveDB in pairs(quest.ObjectiveData) do
            if objectiveDB.Type == "item" then
                if not ((QuestieDB.ItemPointers or QuestieDB.itemData)[objectiveDB.Id]) then
                    Questie:Debug(Questie.DEBUG_DEVELOP,
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
                            Questie:Debug(Questie.DEBUG_DEVELOP,
                                          "Created item information for item:",
                                          itemName, ":", objectiveDB.Id)
                        end)
                end
            end
        end
    end
end

function QuestieLib:Euclid(x, y, i, e)
    -- No need for absolute values as these are used only as squared
    local xd = x - i
    local yd = y - e
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

local cachedTitle
local cachedVersion
-- Move to Questie.lua after QuestieOptions move.
function QuestieLib:GetAddonVersionInfo()
    if (not cachedTitle) or (not cachedVersion) then
        local name, title = GetAddOnInfo("Questie")
        cachedTitle = title
        cachedVersion = GetAddOnMetadata(name, "Version")
    end

    -- %d = digit, %p = punctuation character, %x = hexadecimal digits.
    local major, minor, patch = string.match(cachedVersion, "(%d+)%p(%d+)%p(%d+)")
    local hash = "nil"

    local buildType

    if string.match(cachedTitle, "ALPHA") then
        buildType = "ALPHA"
    elseif string.match(cachedTitle, "BETA") then
        buildType = "BETA"
    end

    return tonumber(major), tonumber(minor), tonumber(patch), tostring(hash), tostring(buildType)
end

function QuestieLib:GetAddonVersionString()
    local major, minor, patch, buildType, hash = QuestieLib:GetAddonVersionInfo()

    if buildType and buildType ~= "nil" then
        buildType = " - " .. buildType
    else
        buildType = ""
    end

    if hash and hash ~= "nil" then
        hash = "-" .. hash
    else
        hash = ""
    end

    return "v" .. tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch) .. hash .. buildType
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
    for _, _ in pairs(table) do count = count + 1 end
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
        local questLevel, _ = QuestieLib:GetTbcLevel(q);
        tinsert(sortedQuestsByLevel, {questLevel or 0, q})
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
    local cost
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
    local low
    local high
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
