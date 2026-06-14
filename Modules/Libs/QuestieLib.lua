local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

---@class QuestieLib
local QuestieLib = QuestieLoader:CreateModule("QuestieLib")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

QuestieLib.AddonPath = "Interface\\Addons\\Questie\\"

local math_abs = math.abs
local math_sqrt = math.sqrt
local math_max = math.max
local math_random = math.random
local tinsert = table.insert
local stringSub = string.sub
local stringGsub = string.gsub
local strim = string.trim
local smatch = string.match
local tonumber = tonumber

-- The original frame which we use to fetch the data required
--                           Classic                          Wotlk Classic
local textWrapFrameObject = _G["QuestLogObjectivesText"] or _G["QuestInfoObjectivesText"]

--[[
    Red: 5+ level above player
    Orange: 3 - 4 level above player
    Yellow: max 2 level below/above player
    Green: 3 - GetQuestGreenRange() level below player (GetQuestGreenRange() changes on specific player levels)
    Gray: More than GetQuestGreenRange() below player
--]]
function QuestieLib:PrintDifficultyColor(level, text, isRepeatableQuest, isEventQuest, isPvPQuest)
    if isEventQuest == true then
        return "|cFF6ce314" .. text .. "|r" -- Lime
    end
    if isPvPQuest == true then
        return "|cFFE35639" .. text .. "|r" -- Maroon
    end
    if isRepeatableQuest == true then
        return "|cFF21CCE7" .. text .. "|r" -- Blue
    end

    if level == -1 then
        level = QuestiePlayer.GetPlayerLevel()
    end
    local levelDiff = level - QuestiePlayer.GetPlayerLevel()

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
    if level == -1 then level = QuestiePlayer.GetPlayerLevel() end
    local levelDiff = level - QuestiePlayer.GetPlayerLevel()

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
    if objective.fulfilled ~= nil and (not objective.Collected) then
        objective.Collected = objective.fulfilled
        objective.Needed = objective.required
    end

    if not objective.Collected or type(objective.Collected) ~= "number" then
        return FloatRGBToHex(0.937, 0.937, 0.937)
    end

    local float = objective.Collected / objective.Needed
    local trackerColor = Questie.db.profile.trackerColorObjectives
    if not trackerColor or trackerColor == "white" or trackerColor == "minimal" then
        -- White
        return "|cFFEEEEEE"
    elseif trackerColor == "whiteAndGreen" then
        -- White and Green
        return objective.Collected == objective.Needed and RGBToHex(40, 255, 40) or FloatRGBToHex(0.937, 0.937, 0.937)
    elseif trackerColor == "whiteToGreen" then
        -- White to Green
        return FloatRGBToHex(0.937 - float / 1.282, 0.937 + float / 15.873, 0.937 - float / 1.282)
    else
        -- Red to Green
        if float <= .50 then return FloatRGBToHex(1, 0 + float * 2, 0) end
        if float > .50 then return FloatRGBToHex(1.843 - float / 0.593, 1, (float * 2 - 1) * 0.157) end
    end
end

---Returns the appropriate objective description based on the trimObjectiveText profile setting
---@param objective QuestObjective
---@return string
function QuestieLib:GetObjectiveDescription(objective)
    if (not objective) then
        return ""
    end
    local desc = objective.FullDescription or objective.Description
    if (not desc) then
        return ""
    end
    return desc:gsub("%.$", "")
end

---@param questId number
---@param showLevel number @ Whether the quest level should be included
---@param showState boolean @ Whether to show (Complete/Failed)
function QuestieLib:GetColoredQuestName(questId, showLevel, showState)
    local name = QuestieDB.QueryQuestSingle(questId, "name")
    local level, _ = QuestieLib.GetTbcLevel(questId);

    if showLevel then
        name = QuestieLib:GetLevelString(questId, level) .. name
    end

    if Questie.db.profile.enableTooltipsQuestID then
        name = name .. " " .. l10n("(") .. questId .. l10n(")")
    end

    if showState then
        local isComplete = QuestieDB.IsComplete(questId)

        if isComplete == -1 then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Failed") .. l10n(")"), "red")
        elseif isComplete == 1 then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Complete") .. l10n(")"), "green")

            -- Quests treated as complete - zero objectives or synthetic objectives
        elseif isComplete == 0 and QuestieDB.GetQuest(questId).isComplete == true then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Complete") .. l10n(")"), "green")
        end
    end

    return QuestieLib:PrintDifficultyColor(level, name, QuestieDB.IsRepeatable(questId), QuestieEvent.IsEventQuest(questId), QuestieDB.IsPvPQuest(questId))
end

-- The order of these colors is important for the ColorWheel function.
-- Taken from https://tailwindcolor.com/
---@type Color[]
local colors = {
    -- Light (200)         Standard (500)         -- Family
    {0.99, 0.73, 0.73},    {0.94, 0.19, 0.19},    -- Red
    {0.99, 0.81, 0.59},    {0.98, 0.46, 0.05},    -- Orange
    {0.99, 0.93, 0.54},    {0.92, 0.68, 0.05},    -- Yellow
    {0.73, 0.96, 0.80},    {0.13, 0.77, 0.36},    -- Green
    {0.75, 0.87, 0.99},    {0.23, 0.55, 0.94},    -- Blue
    {0.78, 0.82, 0.99},    {0.39, 0.45, 0.94},    -- Indigo
    {0.87, 0.82, 1.00},    {0.55, 0.35, 0.96},    -- Violet
    {0.99, 0.76, 0.89},    {0.93, 0.16, 0.55},    -- Pink
}

-- Shuffle colors on startup (Fisher-Yates)
local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math_random(1, i)
        t[i], t[j] = t[j], t[i]
    end
end

shuffleTable(colors)

local numColors = #colors
local lastColor = math_random(numColors)

---@return Color
function QuestieLib:ColorWheel()
    lastColor = lastColor + 1
    if lastColor > numColors then
        lastColor = 1
    end
    return colors[lastColor]
end

--- There are quests in TBC which have a quest level of -1. This indicates that the quest level is the
--- same as the player level. This function should be used whenever accessing the quest or required level.
---@param questId QuestId
---@param playerLevel Level? ---@ PlayerLevel, if nil we fetch current level
---@return Level questLevel
---@return Level requiredLevel
---@return Level requiredMaxLevel
function QuestieLib.GetTbcLevel(questId, playerLevel)
    local questLevel, requiredLevel = QuestieDB.QueryQuestSingle(questId, "questLevel"), QuestieDB.QueryQuestSingle(questId, "requiredLevel")
    if (questLevel == -1) then
        local level = playerLevel or QuestiePlayer.GetPlayerLevel();
        if (requiredLevel > level) then
            questLevel = requiredLevel;
        else
            questLevel = level;
            -- We also set the requiredLevel to the player level so the quest is not hidden without "show low level quests"
            requiredLevel = level;
        end
    end
    return questLevel, requiredLevel, QuestieDB.QueryQuestSingle(questId, "requiredMaxLevel");
end

---Returns the quest type suffix character (e.g., "+" for Elite, "D" for Dungeon)
---@param questId QuestId
---@return string suffix @The suffix character for the quest type
function QuestieLib:GetQuestTypeSuffix(questId)
    local questTagId, questTagName = QuestieDB.GetQuestTagInfo(questId)

    if not questTagId or not questTagName then
        return ""
    end

    local questTagIds = QuestieDB.questTagIds
    local langCode = l10n:GetUILocale()
    local isMultiByteLocale = langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU"

    if questTagId == questTagIds.ELITE then
        return "+"
    elseif questTagId == questTagIds.PVP or questTagId == questTagIds.CLASS or questTagId == questTagIds.ESCORT then
        return ""
    elseif questTagId == questTagIds.LEGENDARY then
        return "++"
    elseif isMultiByteLocale then
        if questTagId == questTagIds.RAID or questTagId == questTagIds.RAID_10 or questTagId == questTagIds.RAID_25 then
            return "R"
        elseif questTagId == questTagIds.DUNGEON then
            return "D"
        elseif questTagId == questTagIds.HEROIC then
            return "H"
        elseif questTagId == questTagIds.SCENARIO then
            return "S"
        elseif questTagId == questTagIds.ACCOUNT then
            return "A"
        elseif questTagId == questTagIds.CELESTIAL then
            return "C"
        elseif questTagId == questTagIds.WORLD_EVENT then
            return "W"
        else
            return ""
        end
    else
        -- Fallback: use first character of quest tag name for unknown tags
        -- This preserves backward compatibility with existing UI/tests
        return stringSub(questTagName, 1, 1)
    end
end

local suffixPriority = {
    [""] = 1, -- No suffix (normal quests) - should come first
    ["+"] = 2, -- Elite
    ["S"] = 3, -- Scenario
    ["D"] = 4, -- Dungeon
    ["H"] = 5, -- Heroic
    ["R"] = 6, -- Raid
    ["++"] = 7, -- Legendary
    ["A"] = 8, -- Account
    ["C"] = 9, -- Celestial
    ["W"] = 10, -- World Event
}

---@param questId QuestId
---@return number priority @The priority of the quest type suffix, lower means higher priority
function QuestieLib.GetQuestTypeSuffixPriority(questId)
    local suffix = QuestieLib:GetQuestTypeSuffix(questId)
    return suffixPriority[suffix] or 999
end

---@param questId QuestId
---@param level Level @The quest level
---@return string levelString @String of format "[40+]"
function QuestieLib:GetLevelString(questId, level)
    local levelString = tostring(level)
    local suffix = QuestieLib:GetQuestTypeSuffix(questId)
    return "[" .. levelString .. suffix .. "] "
end

function QuestieLib:GetRaceString(raceMask)
    if not raceMask or raceMask == QuestieDB.raceKeys.NONE then
        return ""
    end

    if raceMask == QuestieDB.raceKeys.ALL_ALLIANCE then
        return "|cFF1E90FF" .. l10n("Alliance") .. "|r"
    elseif raceMask == QuestieDB.raceKeys.ALL_HORDE then
        return "|cFFDA4450" .. l10n("Horde") .. "|r"
    else
        local raceString = ""
        local raceTable = QuestieLib:UnpackBinary(raceMask)
        local langCode = l10n:GetUILocale()
        local spaceString = ((langCode == "zhCN" or langCode == "zhTW") and "") or " " -- no spaces for chinese strings
        local stringTable = {
            l10n("Human"),                                          -- 1
            l10n("Orc"),                                            -- 2
            l10n("Dwarf"),                                          -- 4
            l10n("Night Elf"),                                      -- 8
            l10n("Undead"),                                         -- 16
            l10n("Tauren"),                                         -- 32
            l10n("Gnome"),                                          -- 64
            l10n("Troll"),                                          -- 128
            l10n("Goblin"),                                         -- 256
            l10n("Blood Elf"),                                      -- 512
            l10n("Draenei"),                                        -- 1024
            nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,                -- 2^11 -> 2^20
            l10n("Worgen"),                                         -- 2097152
            nil,                                                    -- 2^22
            l10n("Pandaren"),                                       -- 8388608
            l10n("Pandaren") .. spaceString .. l10n("Alliance"),    -- 16777216
            l10n("Pandaren") .. spaceString .. l10n("Horde"),       -- 33554432
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

function QuestieLib:GetClassString(classMask)
    if not classMask or classMask == QuestieDB.classKeys.NONE or classMask == QuestieDB.classKeys.ALL_CLASSES then
        return ""
    else
        local classString = ""
        local classTable = QuestieLib:UnpackBinary(classMask)
        local classColors = {
            -- Class colors taken from RAID_CLASS_COLORS["WARRIOR"] etc
            WARRIOR      = "|c" .. RAID_CLASS_COLORS["WARRIOR"].colorStr,
            PALADIN      = "|c" .. RAID_CLASS_COLORS["PALADIN"].colorStr,
            HUNTER       = "|c" .. RAID_CLASS_COLORS["HUNTER"].colorStr,
            ROGUE        = "|c" .. RAID_CLASS_COLORS["ROGUE"].colorStr,
            PRIEST       = "|c" .. RAID_CLASS_COLORS["PRIEST"].colorStr,
            DEATH_KNIGHT = "|c" .. RAID_CLASS_COLORS["DEATHKNIGHT"].colorStr,
            SHAMAN       = "|c" .. RAID_CLASS_COLORS["SHAMAN"].colorStr,
            MAGE         = "|c" .. RAID_CLASS_COLORS["MAGE"].colorStr,
            WARLOCK      = "|c" .. RAID_CLASS_COLORS["WARLOCK"].colorStr,
            MONK         = "|c" .. RAID_CLASS_COLORS["MONK"].colorStr,
            DRUID        = "|c" .. RAID_CLASS_COLORS["DRUID"].colorStr,
        }
        local stringTable = {
            classColors.WARRIOR .. l10n("Warrior") .. "|r",                 -- 1
            classColors.PALADIN .. l10n("Paladin") .. "|r",                 -- 2
            classColors.HUNTER .. l10n("Hunter") .. "|r",                   -- 4
            classColors.ROGUE .. l10n("Rogue") .. "|r",                     -- 8
            classColors.PRIEST .. l10n("Priest") .. "|r",                   -- 16
            classColors.DEATH_KNIGHT .. l10n("Death Knight") .. "|r",       -- 32
            classColors.SHAMAN .. l10n("Shaman") .. "|r",                   -- 64
            classColors.MAGE .. l10n("Mage") .. "|r",                       -- 128
            classColors.WARLOCK .. l10n("Warlock") .. "|r",                 -- 256
            classColors.MONK .. l10n("Monk") .. "|r",                       -- 512
            classColors.DRUID .. l10n("Druid") .. "|r",                     -- 1024
        }
        local firstRun = true
        for k, v in pairs(classTable) do
            if v then
                if firstRun then
                    firstRun = false
                else
                    classString = classString .. ", "
                end
                classString = classString .. stringTable[k]
            end
        end
        return classString
    end
end

function QuestieLib:CacheItemNames(questId)
    local quest = QuestieDB.GetQuest(questId)
    if (quest and quest.ObjectiveData) then
        for _, objectiveDB in pairs(quest.ObjectiveData) do
            if objectiveDB.Type == "item" then
                if not ((QuestieDB.ItemPointers or QuestieDB.itemData)[objectiveDB.Id]) then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieLib:CacheItemNames] Requesting item information for missing itemId:", objectiveDB.Id)
                    local item = Item:CreateFromItemID(objectiveDB.Id)
                    item:ContinueOnItemLoad(
                        function()
                            local itemName = item:GetItemName()
                            if not QuestieDB.itemDataOverrides[objectiveDB.Id] then
                                QuestieDB.itemDataOverrides[objectiveDB.Id] = {itemName, {questId}, {}, {}}
                            else
                                QuestieDB.itemDataOverrides[objectiveDB.Id][1] = itemName
                            end
                            Questie:Debug(Questie.DEBUG_DEVELOP,
                                "[QuestieLib:CacheItemNames] Created item information for item:", itemName, ":", objectiveDB.Id)
                        end)
                end
            end
        end
    end
end

function QuestieLib.Euclid(x, y, i, e)
    -- No need for absolute values as these are used only as squared
    local xd = x - i
    local yd = y - e
    return math_sqrt(xd * xd + yd * yd)
end

function QuestieLib:Maxdist(x, y, i, e)
    return math_max(math_abs(x - i), math_abs(y - e))
end

local cachedVersion

---@return number, number, number
function QuestieLib:GetAddonVersionInfo()
    if (not cachedVersion) then
        cachedVersion = GetAddOnMetadata("Questie", "Version")
    end

    local major, minor, patch = string.match(cachedVersion, "(%d+)%p(%d+)%p(%d+)")

    return tonumber(major), tonumber(minor), tonumber(patch)
end

function QuestieLib:GetAddonVersionString()
    if (not cachedVersion) then
        -- This brings up the ## Version from the TOC
        cachedVersion = GetAddOnMetadata("Questie", "Version")
    end

    return "v" .. cachedVersion
end

-- According to stack overflow, # and table.getn arent reliable (I've experienced this? not sure whats up)
function QuestieLib:Count(table)
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
        ret = stringGsub(ret, "([%+%-%*%(%)%?%[%]%^])", "%%%1")
        -- remove capture indexes
        ret = stringGsub(ret, "%d%$", "")
        -- catch all characters
        ret = stringGsub(ret, "(%%%a)", "%(%1+%)")
        -- convert all %s to .+
        ret = stringGsub(ret, "%%s%+", ".+")
        -- set priority to numbers over strings
        ret = stringGsub(ret, "%(.%+%)%(%%d%+%)", "%(.-%)%(%%d%+%)")
        -- cache it
        sanitize_cache[pattern] = ret
    end

    return sanitize_cache[pattern]
end

local function compareQuestsByLevelAndType(a, b)
    if a[1] ~= b[1] then
        return a[1] < b[1]
    end

    -- if levels are the same, compare by suffix priority
    local suffixA = a[3] or ""
    local suffixB = b[3] or ""
    local priorityA = suffixPriority[suffixA] or 999
    local priorityB = suffixPriority[suffixB] or 999

    if priorityA ~= priorityB then
        return priorityA < priorityB
    end

    return a[2] < b[2]
end

---@param quests table<QuestId, any>
---@return table A sorted table of quests, sorted by level and then by type (Elite, Dungeon, etc.)
function QuestieLib:SortQuestIDsByLevel(quests)
    local sortedQuestsByLevel = {}

    for questId in pairs(quests) do
        local questLevel, _ = QuestieLib.GetTbcLevel(questId)
        local suffix = QuestieLib:GetQuestTypeSuffix(questId)
        tinsert(sortedQuestsByLevel, {questLevel or 0, questId, suffix})
    end
    table.sort(sortedQuestsByLevel, compareQuestsByLevelAndType)

    return sortedQuestsByLevel
end

function QuestieLib:UnpackBinary(val)
    local ret = {}
    for q = 0, 25 do
        if bit.band(bit.rshift(val, q), 1) == 1 then
            tinsert(ret, true)
        else
            tinsert(ret, false)
        end
    end
    return ret
end

-- Link contains test bench for regex in lua.
-- https://hastebin.com/anodilisuw.bash
-- QUEST_MONSTERS_KILLED etc. patterns are from WoW API
local L_QUEST_MONSTERS_KILLED = QuestieLib:SanitizePattern(QUEST_MONSTERS_KILLED)
local L_QUEST_ITEMS_NEEDED = QuestieLib:SanitizePattern(QUEST_ITEMS_NEEDED)
local L_QUEST_OBJECTS_FOUND = QuestieLib:SanitizePattern(QUEST_OBJECTS_FOUND)

--- 'FooBar slain: 0/3' --> 'FooBar'
--- 'EpicItem : 0/1' --> 'EpicItem'
---@param text string @requires nil check and first character ~= " " check before call
---@param objectiveType string
function QuestieLib.TrimObjectiveText(text, objectiveType)
    local originalText = text

    if objectiveType == "monster" then
        local n, _, monsterName = smatch(text, L_QUEST_MONSTERS_KILLED)
        if tonumber(monsterName) then -- SOME objectives are reversed in TBC, why blizzard?
            monsterName = n
        end

        if (not monsterName) or (strlen(monsterName) == strlen(originalText)) then
            --The above doesn't seem to work with the chinese, the row below tries to remove the extra numbers.
            text = smatch(monsterName or text, "(.*)：");
        else
            text = monsterName
        end
    elseif objectiveType == "item" then
        local n, _, itemName = smatch(text, L_QUEST_ITEMS_NEEDED)
        if tonumber(itemName) then -- SOME objectives are reversed in TBC, why blizzard?
            itemName = n
        end

        text = itemName
    elseif objectiveType == "object" then
        local n, _, objectName = smatch(text, L_QUEST_OBJECTS_FOUND)
        if tonumber(objectName) then -- SOME objectives are reversed in TBC, why blizzard?
            objectName = n
        end

        text = objectName
    end

    -- If the functions above do not give a good answer fall back to older regex to get something.
    if not text then
        text = smatch(originalText, "^(.*):%s") or smatch(originalText, "%s：(.*)$") or smatch(originalText, "^(.*)：%s") or originalText
    end

    text = strim(text)
    --Questie:Debug(Questie.DEBUG_DEVELOP, "[TrimObjectiveText] \""..originalText.."\" --> \""..text.."\"") -- Comment out this debug for speed when not used.
    return text
end

---@return boolean
function QuestieLib.equals(a, b)
    if a == nil and b == nil then return true end
    if a == nil or b == nil then return false end
    local ta = type(a)
    local tb = type(b)
    if ta ~= tb then return false end

    if ta == "number" then
        return math.abs(a - b) < 0.2
    elseif ta == "table" then
        for k, v in pairs(a) do
            if (not QuestieLib.equals(b[k], v)) then
                return false
            end
        end
        for k, v in pairs(b) do
            if (not QuestieLib.equals(a[k], v)) then
                return false
            end
        end
        return true
    end

    return a == b
end

---@return table A table of the handed parameters plus the 'n' field with the size of the table
function QuestieLib.tpack(...)
    return {n = select("#", ...), ...}
end

--- Wow's own unpack stops at first nil. this version is not speed optimized.
--- Supports just above QuestieLib.tpack func as it requires the 'n' field.
---@param tbl table A table packed with QuestieLib.tpack
---@return table|nil 'n' values of the tbl
function QuestieLib.tunpack(tbl)
    if tbl.n == 0 then
        return nil
    end

    local function recursion(i)
        if i == tbl.n then
            return tbl[i]
        end
        return tbl[i], recursion(i + 1)
    end

    return recursion(1)
end

---@alias TableWeakMode
---| '"v"'        # Weak Value
---| '"k"'        # Weak Key
---| '"kv"'       # Weak Value and Weak Key
---| '""'         # Regular table

---* Memoize a function with a cache
--! This does not support nil, never input nil into the table
---@param func function
---@param __mode TableWeakMode?
---@return table
function QuestieLib:TableMemoizeFunction(func, __mode)
    return setmetatable({}, {
        __index = function(self, k)
            local v = func(k);
            self[k] = v
            return v;
        end,
        __mode = __mode or ""
    });
end

--Part of the GameTooltipWrapDescription function
local textWrapObjectiveFontString
-- These Chinese punctuation marks should stay at the end of the previous line.
-- Starting a new line with punctuation looks wrong and can happen because Chinese text has no spaces.
local CHINESE_PUNCTUATION = {
    ["；"] = true,
    ["！"] = true,
    ["？"] = true,
    ["。"] = true,
    ["，"] = true,
    ["："] = true,
    ["、"] = true,
}

local FULLWIDTH_DIGITS = {
    ["０"] = true,
    ["１"] = true,
    ["２"] = true,
    ["３"] = true,
    ["４"] = true,
    ["５"] = true,
    ["６"] = true,
    ["７"] = true,
    ["８"] = true,
    ["９"] = true,
}
local NUMERIC_SEPARATORS = {
    [","] = true,
    ["."] = true,
    ["，"] = true,
    ["．"] = true,
}
-- Keep numeric suffixes conservative and exact. These counters/units commonly attach to quest numbers,
-- but single characters like "经" or "钟" can also appear inside normal words, so only glue full suffix tokens.
local NUMERIC_SUFFIXES = {
    "分钟",
    "分鐘",
    "经验",
    "經驗",
    "个",
    "個",
    "块",
    "塊",
    "秒",
    "次",
    "级",
    "級",
    "点",
    "點",
    "只",
    "隻",
    "件",
    "名",
    "份",
    "颗",
    "顆",
    "枚",
    "条",
    "條",
    "本",
    "层",
    "層",
    "组",
    "組",
    "码",
    "碼",
}

local function _IsChinesePunctuation(character)
    return CHINESE_PUNCTUATION[character] == true
end

local function _IsNumericCharacter(character)
    return string.match(character, "^%d$") ~= nil or FULLWIDTH_DIGITS[character] == true
end

local function _IsNumericTokenCharacter(line, index, lineLength)
    if (index < 1 or index > lineLength) then
        return false
    end

    local character = utf8.sub(line, index, index)
    if (_IsNumericCharacter(character)) then
        return true
    elseif (character == "%" or character == "％") then
        return _IsNumericCharacter(utf8.sub(line, index - 1, index - 1))
    elseif (NUMERIC_SEPARATORS[character]) then
        return _IsNumericCharacter(utf8.sub(line, index - 1, index - 1)) and _IsNumericCharacter(utf8.sub(line, index + 1, index + 1))
    end

    return false
end

local function _GetNumericSuffixLengthAtStart(line, suffixStartIndex, lineLength)
    if (suffixStartIndex < 1 or suffixStartIndex > lineLength) then
        return 0
    end

    for _, suffix in ipairs(NUMERIC_SUFFIXES) do
        local suffixLength = utf8.strlen(suffix)
        local suffixEndIndex = suffixStartIndex + suffixLength - 1
        if (suffixEndIndex <= lineLength and utf8.sub(line, suffixStartIndex, suffixEndIndex) == suffix) then
            return suffixLength
        end
    end

    return 0
end

local function _GetNumericSuffixEndIndexAt(line, index, lineLength)
    for _, suffix in ipairs(NUMERIC_SUFFIXES) do
        local suffixLength = utf8.strlen(suffix)
        for offset = 0, suffixLength - 1 do
            local suffixStartIndex = index - offset
            local suffixEndIndex = suffixStartIndex + suffixLength - 1
            if (suffixStartIndex >= 1
                and suffixEndIndex <= lineLength
                and utf8.sub(line, suffixStartIndex, suffixEndIndex) == suffix
                and _IsNumericTokenCharacter(line, suffixStartIndex - 1, lineLength)
            ) then
                return suffixEndIndex
            end
        end
    end

    return nil
end

local function _MoveNumericSuffixToPreviousLine(line, lineLength, lineEndIndex, nextStartIndex)
    local suffixLength = _GetNumericSuffixLengthAtStart(line, nextStartIndex, lineLength)
    if (suffixLength > 0) then
        lineEndIndex = nextStartIndex + suffixLength - 1
        nextStartIndex = lineEndIndex + 1
    end

    return lineEndIndex, nextStartIndex
end

local function _SetTextWrapFont(textWrapFontString, fontSource)
    local fontSourceType = type(fontSource)
    if (fontSource and (fontSourceType == "table" or fontSourceType == "userdata") and type(fontSource.GetFont) == "function") then
        local font, size, flags = fontSource:GetFont()
        if (font and size) then
            textWrapFontString:SetFont(font, size, flags)
            return
        end
    end

    local font, size, flags = textWrapFrameObject:GetFont()
    textWrapFontString:SetFont(font, size, flags)
end

local function _GetPreferredWrapIndex(lastSpaceIndex, lastPunctuationIndex, lineEndIndex)
    if (lastSpaceIndex) then
        return lastSpaceIndex, lastSpaceIndex + 1, true
    elseif (lastPunctuationIndex) then
        return lastPunctuationIndex, lastPunctuationIndex + 1, false
    end

    return lineEndIndex, lineEndIndex + 1, false
end

local function _UpdateLastBreakIndexes(character, index, lastSpaceIndex, lastPunctuationIndex)
    if (character == " ") then
        return index, lastPunctuationIndex
    elseif (_IsChinesePunctuation(character)) then
        return lastSpaceIndex, index
    end

    return lastSpaceIndex, lastPunctuationIndex
end

local function _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
    local lastSpaceIndex
    local lastPunctuationIndex

    for endIndex = 1, lineLength do
        local character = utf8.sub(line, endIndex, endIndex)
        lastSpaceIndex, lastPunctuationIndex = _UpdateLastBreakIndexes(character, endIndex, lastSpaceIndex, lastPunctuationIndex)

        textWrapFontString:SetText(utf8.sub(line, 1, endIndex))

        if (textWrapFontString:GetUnboundedStringWidth() > textWrapFontString:GetWrappedWidth()) then
            local lineEndIndex = math_max(endIndex - 1, 1)
            return _GetPreferredWrapIndex(lastSpaceIndex, lastPunctuationIndex, lineEndIndex)
        end
    end

    return lineLength, lineLength + 1, false
end

local function _GetTextWrapBreak(textWrapFontString, line, lineLength)
    if (not string.find(line, " ", 1, true) and textWrapFontString:GetUnboundedStringWidth() > textWrapFontString:GetWrappedWidth()) then
        local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
        textWrapFontString:SetText(line)
        return lineEndIndex, nextStartIndex, brokeAtSpace
    end

    local endIndex = 1
    local lastSpaceIndex
    local lastPunctuationIndex

    -- Walk until this span would wrap to a second visual row.
    while (endIndex <= lineLength) do
        local character = utf8.sub(line, endIndex, endIndex)
        lastSpaceIndex, lastPunctuationIndex = _UpdateLastBreakIndexes(character, endIndex, lastSpaceIndex, lastPunctuationIndex)

        local indexes = textWrapFontString:CalculateScreenAreaFromCharacterSpan(1, endIndex)
        if (not indexes) then
            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
            textWrapFontString:SetText(line)
            return lineEndIndex, nextStartIndex, brokeAtSpace
        elseif (#indexes > 1) then
            break
        end

        endIndex = endIndex + 1
    end

    if (endIndex > lineLength) then
        -- Some clients/fonts do not wrap Chinese text without spaces, so the FontString reports one visual row.
        -- In that case split by measured width instead.
        if (textWrapFontString:GetUnboundedStringWidth() > textWrapFontString:GetWrappedWidth()) then
            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
            textWrapFontString:SetText(line)
            return lineEndIndex, nextStartIndex, brokeAtSpace
        end

        return lineLength, lineLength + 1, false
    end

    -- No space or punctuation exists on this row, so split at the last fitting UTF-8 character.
    local lineEndIndex = math_max(endIndex - 1, 1)

    return _GetPreferredWrapIndex(lastSpaceIndex, lastPunctuationIndex, lineEndIndex)
end

local function _MoveNumberToPreviousLine(line, lineLength, lineEndIndex, nextStartIndex)
    if (lineEndIndex < 1 or nextStartIndex > lineLength) then
        return lineEndIndex, nextStartIndex
    end

    local suffixEndIndex = _GetNumericSuffixEndIndexAt(line, lineEndIndex, lineLength)
    if (not _IsNumericTokenCharacter(line, lineEndIndex, lineLength)) then
        if (suffixEndIndex and nextStartIndex <= suffixEndIndex) then
            return suffixEndIndex, suffixEndIndex + 1
        end

        return lineEndIndex, nextStartIndex
    end

    local movedNumericToken = false
    while (nextStartIndex <= lineLength and _IsNumericTokenCharacter(line, nextStartIndex, lineLength)) do
        lineEndIndex = nextStartIndex
        nextStartIndex = nextStartIndex + 1
        movedNumericToken = true
    end

    lineEndIndex, nextStartIndex = _MoveNumericSuffixToPreviousLine(line, lineLength, lineEndIndex, nextStartIndex)

    if movedNumericToken then
        while (nextStartIndex <= lineLength and utf8.sub(line, nextStartIndex, nextStartIndex) == " ") do
            lineEndIndex = nextStartIndex
            nextStartIndex = nextStartIndex + 1
        end
    end

    return lineEndIndex, nextStartIndex
end

local function _MovePunctuationToPreviousLine(line, lineLength, lineEndIndex, nextStartIndex)
    while (nextStartIndex <= lineLength and _IsChinesePunctuation(utf8.sub(line, nextStartIndex, nextStartIndex))) do
        lineEndIndex = nextStartIndex
        nextStartIndex = nextStartIndex + 1
    end

    return lineEndIndex, nextStartIndex
end

local function _GetRemainingRows(textWrapFontString, remainingLine, lastLine, nextStartIndex, remainingLineLength)
    local remainingIndexes = textWrapFontString:CalculateScreenAreaFromCharacterSpan(nextStartIndex, remainingLineLength)
    if remainingIndexes then
        return #remainingIndexes
    end

    textWrapFontString:SetText(lastLine)
    local remainingRows = textWrapFontString:GetUnboundedStringWidth() <= textWrapFontString:GetWrappedWidth() and 1 or 2
    textWrapFontString:SetText(remainingLine)

    return remainingRows
end

local function _ShouldCombineTrailingLine(textWrapFontString, remainingLine, nextStartIndex, remainingLineLength, brokeAtSpace)
    if (nextStartIndex > remainingLineLength) then
        return false
    end

    local lastLine = utf8.sub(remainingLine, nextStartIndex, remainingLineLength)
    if (_GetRemainingRows(textWrapFontString, remainingLine, lastLine, nextStartIndex, remainingLineLength) ~= 1) then
        return false
    end

    return (brokeAtSpace and not string.find(lastLine, " ")) or (utf8.strlen(lastLine) == 1 and string.len(lastLine) > 1)
end

---Emulates the wrapping of a quest description
---@param line string @The line to wrap
---@param prefix string @The prefix to add to the line
---@param combineTrailing boolean @If the last line is only one word, combine it with previous? TRUE=COMBINE, FALSE=NOT COMBINE, default: true
---@param desiredWidth number @Set the desired width to wrap, default: 275
---@param fontSource table? @Optional FontString to copy the measuring font from
---@return table[] @A table of wrapped lines
function QuestieLib:TextWrap(line, prefix, combineTrailing, desiredWidth, fontSource)
    if not textWrapObjectiveFontString then
        textWrapObjectiveFontString = UIParent:CreateFontString("questieObjectiveTextString", "ARTWORK", "QuestFont")
        textWrapObjectiveFontString:SetWidth(textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
        textWrapObjectiveFontString:SetHeight(0);
        textWrapObjectiveFontString:SetPoint("LEFT");
        textWrapObjectiveFontString:SetJustifyH("LEFT");
        ---@diagnostic disable-next-line: redundant-parameter
        textWrapObjectiveFontString:SetWordWrap(true)
        textWrapObjectiveFontString:SetVertexColor(1, 1, 1, 1) --Set opacity to 0, even if it is shown it should be invisible
        --Chinese? "Fonts\\ARKai_T.ttf"
        _SetTextWrapFont(textWrapObjectiveFontString)
        textWrapObjectiveFontString:Hide()
    end

    if (textWrapObjectiveFontString:IsVisible()) then Questie:Error("TextWrap already running... Please report this on GitHub or Discord.") end

    --Set Defaults
    if (combineTrailing == nil) then
        combineTrailing = true
    end
    --We show the fontstring and set the text to start the process
    --We have to show it or else the functions won't work... But we set the opacity to 0 on creation
    _SetTextWrapFont(textWrapObjectiveFontString, fontSource)
    textWrapObjectiveFontString:SetWidth(desiredWidth or textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
    textWrapObjectiveFontString:Show()

    local useLine = line
    local lineLength = utf8.strlen(useLine)

    textWrapObjectiveFontString:SetText(useLine)
    --Is the line wrapped?
    if (textWrapObjectiveFontString:GetUnboundedStringWidth() > textWrapObjectiveFontString:GetWrappedWidth()) then
        local lines = {}
        local startIndex = 1

        while (startIndex <= lineLength) do
            local remainingLine = utf8.sub(useLine, startIndex, lineLength)
            local remainingLineLength = utf8.strlen(remainingLine)

            -- Recalculate each remaining line. If we skip spaces or move punctuation, the original FontString rows no longer match.
            textWrapObjectiveFontString:SetText(remainingLine)
            if (textWrapObjectiveFontString:GetUnboundedStringWidth() <= textWrapObjectiveFontString:GetWrappedWidth()) then
                tinsert(lines, prefix .. remainingLine)
                break
            end

            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreak(textWrapObjectiveFontString, remainingLine, remainingLineLength)
            lineEndIndex, nextStartIndex = _MoveNumberToPreviousLine(remainingLine, remainingLineLength, lineEndIndex, nextStartIndex)
            lineEndIndex, nextStartIndex = _MovePunctuationToPreviousLine(remainingLine, remainingLineLength, lineEndIndex, nextStartIndex)

            local newLine = utf8.sub(remainingLine, 1, lineEndIndex)

            --This combines a trailing word or glyph to the previous line if it would be alone on the last line.
            if (combineTrailing and _ShouldCombineTrailingLine(textWrapObjectiveFontString, remainingLine, nextStartIndex, remainingLineLength, brokeAtSpace)) then
                newLine = remainingLine
                tinsert(lines, prefix .. newLine)
                break
            end

            tinsert(lines, prefix .. newLine)
            startIndex = startIndex + nextStartIndex - 1
        end
        textWrapObjectiveFontString:Hide()
        return lines
    else
        --Line was not wrapped, return the string as is.
        textWrapObjectiveFontString:Hide()
        useLine = prefix .. line
        return {useLine}
    end
end

function QuestieLib.GetSpawnDistance(spawnA, spawnB)
    local x1, y1 = spawnA[1], spawnA[2]
    local x2, y2 = spawnB[1], spawnB[2]

    -- Adjust the x-coordinate to account the map scale
    local distanceX = (x1 - x2) * 1.5
    local distanceY = y1 - y2

    return math_sqrt(distanceX * distanceX + distanceY * distanceY)
end

---@param quest Quest
---@return number iconType The number representing the type of icon
function QuestieLib.GetQuestIcon(quest)
    if Questie.IsSoD and QuestieDB.IsSoDRuneQuest(quest.Id) then
        return Questie.ICON_TYPE_SODRUNE
    elseif QuestieDB.IsActiveEventQuest(quest.Id) then
        return Questie.ICON_TYPE_EVENTQUEST
    end
    if QuestieDB.IsPvPQuest(quest.Id) then
        return Questie.ICON_TYPE_PVPQUEST
    end
    if quest.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        return Questie.ICON_TYPE_AVAILABLE_GRAY
    end
    if quest.IsRepeatable then
        return Questie.ICON_TYPE_REPEATABLE
    end
    if QuestieDB.IsTrivial(quest.level) then
        return Questie.ICON_TYPE_AVAILABLE_GRAY
    end
    return Questie.ICON_TYPE_AVAILABLE
end

--- Checks if a daily reset has occurred since the player's last login.
---@return boolean True if a daily reset has occurred, false otherwise.
function QuestieLib.DidDailyResetHappenSinceLastLogin()
    local realmName = GetRealmName()
    local lastKnownDailyReset = Questie.db.global.lastKnownDailyReset[realmName]

    if (not lastKnownDailyReset) then
        return true -- No previous login recorded, assume a reset has occurred
    end

    return GetServerTime() >= lastKnownDailyReset
end

--- Updates the last known daily reset time to the next reset time.
function QuestieLib.UpdateLastKnownDailyReset()
    local realmName = GetRealmName()

    Questie.db.global.lastKnownDailyReset[realmName] = GetServerTime() + GetQuestResetTime()
end

---@param timeStamp number
---@return string|osdate formattedDate The date formatted based on the player's locale
function QuestieLib.FormatDate(timeStamp)
    local langCode = l10n:GetUILocale()

    local weekDay = CALENDAR_WEEKDAY_NAMES[tonumber(date("%w", timeStamp)) + 1]
    local monthName = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(date("%m", timeStamp))]

    if langCode == "deDE" then
        return date(weekDay .. ", %d. " .. monthName .. " %Y um %H:%M", timeStamp)
    elseif langCode == "esES" or langCode == "esMX" then
        return date(weekDay .. ", %d de " .. monthName .. " de %Y a las %H:%M", timeStamp)
    elseif langCode == "frFR" then
        return date(weekDay .. " %d " .. monthName .. " %Y à %H:%M", timeStamp)
    elseif langCode == "koKR" then
        return date("%Y년 " .. monthName .. " %d일" .. " " .. weekDay .." %H:%M", timeStamp)
    elseif langCode == "ptBR" then
        return date(weekDay .. ", %d de " .. monthName .. " de %Y às %H:%M", timeStamp)
    elseif langCode == "ruRU" then
        return date(weekDay .. ", %d " .. monthName .. " %Y, %H:%M", timeStamp)
    elseif langCode == "zhCN" or langCode == "zhTW" then
        return date("%Y年" .. monthName .. "%d日 " .. weekDay .. " %H:%M", timeStamp)
    end

    return date(weekDay .. ", " .. monthName .. " %d, %Y at %H:%M", timeStamp)
end

return QuestieLib
