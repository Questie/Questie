local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

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
function QuestieLib:PrintDifficultyColor(level, text, isDailyQuest, isEventQuest, isPvPQuest)
    if isEventQuest == true then
        return "|cFF6ce314" .. text .. "|r" -- Lime
    end
    if isPvPQuest == true then
        return "|cFFE35639" .. text .. "|r" -- Maroon
    end
    if isDailyQuest == true then
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
        return FloatRGBToHex(0.8, 0.8, 0.8)
    end

    local float = objective.Collected / objective.Needed
    local trackerColor = Questie.db.global.trackerColorObjectives
    if not trackerColor or trackerColor == "white" then
        -- White
        return "|cFFEEEEEE"
    elseif trackerColor == "whiteAndGreen" then
        -- White and Green
        return objective.Collected == objective.Needed and RGBToHex(76, 255, 76) or FloatRGBToHex(0.8, 0.8, 0.8)
    elseif trackerColor == "whiteToGreen" then
        -- White to Green
        return FloatRGBToHex(0.8 - float / 2, 0.8 + float / 3, 0.8 - float / 2)
    else
        -- Red to Green
        if float < .50 then return FloatRGBToHex(1, 0 + float / .5, 0) end
        if float == .50 then return FloatRGBToHex(1, 1, 0) end
        if float > .50 then return FloatRGBToHex(1 - float / 2, 1, 0) end
    end
end

---@param questId number
---@param showLevel number @ Whether the quest level should be included
---@param showState boolean @ Whether to show (Complete/Failed)
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetColoredQuestName(questId, showLevel, showState, blizzLike)
    local name = QuestieDB.QueryQuestSingle(questId, "name");
    local level, _ = QuestieLib.GetTbcLevel(questId);

    if showLevel then
        name = QuestieLib:GetQuestString(questId, name, level, blizzLike)
    end
    if Questie.db.global.enableTooltipsQuestID then
        name = name .. " (" .. questId .. ")"
    end

    if showState then
        local isComplete = QuestieDB.IsComplete(questId)

        if isComplete == -1 then
            name = name .. " (" .. l10n("Failed") .. ")"
        elseif isComplete == 1 then
            name = name .. " (" .. l10n("Complete") .. ")"
        end
    end

    return QuestieLib:PrintDifficultyColor(level, name, QuestieDB.IsRepeatable(questId), QuestieDB.IsActiveEventQuest(questId), QuestieDB.IsPvPQuest(questId))
end

local colors = {
    { 0.3125,     0.44140625, 1 },          --Blizzard Polygon-blue --Alpha of 128
    --{123,         146,        255},         --Blizzard Polygon-blue-2 --Alpha of 61
    { 0.5,        0.46875,    0.84765625 }, --Medium Purple
    { 0.58203125, 0.89453125, 0.0546875 },  --Inch Worm
    { 0.45703125, 0.8515625,  0.78125 },    --Downy
    { 1,          0.5625,     0.625 },      --Salmon Pink
    --{149,         159,        112},         --Avocado, Bad? Fix it
    { 0,          0.6484375,  0.59375 },    --Persian Green
    { 0.70703125, 0.109375,   0.4765625 },  --Medium Violet Red     --ORG Dark Purple {119, 18,  79}
    { 0.58203125, 0.2148375,  1 },          --Light Slate Blue
    { 0.72265625, 0.3671875,  0 },          --Alloy Orange
    { 0,          0.9765625,  0.546875 },   --Spring Green
    { 0.8515625,  0.2148375,  0.57421875 }, --Deep Cerise
    { 1,          0.65234375, 0 },          --Orange
    { 0.8125,     0.7109375,  1 },          --Mauve
    { 0,          0.25390625, 0.58984375 }, --Smalt
    { 1,          0.25,       1 },          --Pink Flamingo
    { 1,          1,          0 },          --Yellow
    { 0.16015625, 0.65234375, 0 },          --Slimy Green
    { 0,          0.66015625, 1 },          --Deep Sky Blue
    { 0.87109375, 0.87109375, 0.56640625 }, --Primrose
    { 0,          0.5859375,  0 },          --Vine Green --G67 default
    { 0,          0.3,        1 },          --Navy Blue
    { 0,          0.97265625, 0 },          --Lime
    { 0,          1,          1 },          --Aqua
    { 1,          0.1484375,  0 },          --Scarlet
}

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

---@return Color
function QuestieLib:GetRandomColor()
    return colors[math_random(numColors)]
end

---@param questId number
---@param name string @The (localized) name of the quest
---@param level number @The quest level
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
function QuestieLib:GetQuestString(questId, name, level, blizzLike)
    local questType, questTag = QuestieDB.GetQuestTagInfo(questId)

    if questType and questTag then
        local char = "+"
        if (not blizzLike) then
            char = stringSub(questTag, 1, 1)
        end

        -- The string.sub above doesn't work for multi byte characters in Chinese
        local langCode = l10n:GetUILocale()
        if questType == 1 then
            -- Elite quest
            name = "[" .. level .. "+" .. "] " .. name
        elseif questType == 81 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "D"
            end
            -- Dungeon quest
            name = "[" .. level .. char .. "] " .. name
        elseif questType == 62 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "R"
            end
            -- Raid quest
            name = "[" .. level .. char .. "] " .. name
        elseif questType == 41 then
            -- Which one? This is just default.
            name = "[" .. level .. "] " .. name
            -- PvP quest
            -- name = "[" .. level .. questTag .. "] " .. name
        elseif questType == 83 then
            -- Legendary quest
            name = "[" .. level .. "++" .. "] " .. name
        else
            -- Some other irrelevant type
            name = "[" .. level .. "] " .. name
        end
    else
        name = "[" .. level .. "] " .. name
    end

    return name
end

--- There are quests in TBC which have a quest level of -1. This indicates that the quest level is the
--- same as the player level. This function should be used whenever accessing the quest or required level.
---@param questId QuestId
---@param playerLevel Level? ---@ PlayerLevel, if nil we fetch current level
---@return Level questLevel, Level requiredLevel @questLevel & requiredLevel
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
    return questLevel, requiredLevel;
end

---@param questId QuestId
---@param level Level @The quest level
---@param blizzLike boolean @True = [40+], false/nil = [40D/R]
---@return string levelString @String of format "[40+]"
function QuestieLib:GetLevelString(questId, _, level, blizzLike)
    local questType, questTag = QuestieDB.GetQuestTagInfo(questId)

    local retLevel = tostring(level)
    if questType and questTag then
        local char = "+"
        if (not blizzLike) then
            char = stringSub(questTag, 1, 1)
        end
        -- the string.sub above doesn't work for multi byte characters in Chinese
        local langCode = l10n:GetUILocale()
        if questType == 1 then
            -- Elite quest
            retLevel = "[" .. retLevel .. "+" .. "] "
        elseif questType == 81 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "D"
            end
            -- Dungeon quest
            retLevel = "[" .. retLevel .. char .. "] "
        elseif questType == 62 then
            if langCode == "zhCN" or langCode == "zhTW" or langCode == "koKR" or langCode == "ruRU" then
                char = "R"
            end
            -- Raid quest
            retLevel = "[" .. retLevel .. char .. "] "
        elseif questType == 41 then
            -- Which one? This is just default.
            retLevel = "[" .. retLevel .. "] "
            -- PvP quest
            -- name = "[" .. level .. questTag .. "] " .. name
        elseif questType == 83 then
            -- Legendary quest
            retLevel = "[" .. retLevel .. "++" .. "] "
        else
            -- Some other irrelevant type
            retLevel = "[" .. retLevel .. "] "
        end
    else
        retLevel = "[" .. retLevel .. "] "
    end

    return retLevel
end

function QuestieLib:GetRaceString(raceMask)
    if not raceMask or raceMask == QuestieDB.raceKeys.NONE then
        return ""
    end

    if raceMask == QuestieDB.raceKeys.ALL_ALLIANCE then
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

function QuestieLib:CacheItemNames(questId)
    local quest = QuestieDB:GetQuest(questId)
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
                                QuestieDB.itemDataOverrides[objectiveDB.Id] = { itemName, { questId }, {}, {} }
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

function QuestieLib:Euclid(x, y, i, e)
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

function QuestieLib:SortQuestIDsByLevel(quests)
    local sortedQuestsByLevel = {}

    local function compareTablesByIndex(a, b)
        return a[1] < b[1]
    end

    for q in pairs(quests) do
        local questLevel, _ = QuestieLib.GetTbcLevel(q);
        tinsert(sortedQuestsByLevel, { questLevel or 0, q })
    end
    table.sort(sortedQuestsByLevel, compareTablesByIndex)

    return sortedQuestsByLevel
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

    randomSeed = (randomSeed * 214013 + 2531011) % 2 ^ 32
    local rand = (math.floor(randomSeed / 2 ^ 16) % 2 ^ 15) / 0x7fff
    if not high then
        return rand
    end
    return low + math.floor(rand * high)
end

function QuestieLib:UnpackBinary(val)
    local ret = {}
    for q = 0, 16 do
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
    return { n = select("#", ...), ... }
end

--- Wow's own unpack stops at first nil. this version is not speed optimized.
--- Supports just above QuestieLib.tpack func as it requires the 'n' field.
---@param tbl table A table packed with QuestieLib.tpack
---@return table 'n' values of the tbl
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
---Emulates the wrapping of a quest description
---@param line string @The line to wrap
---@param prefix string @The prefix to add to the line
---@param combineTrailing boolean @If the last line is only one word, combine it with previous? TRUE=COMBINE, FALSE=NOT COMBINE, default: true
---@param desiredWidth number @Set the desired width to wrap, default: 275
---@return table[] @A table of wrapped lines
function QuestieLib:TextWrap(line, prefix, combineTrailing, desiredWidth)
    if not textWrapObjectiveFontString then
        textWrapObjectiveFontString = UIParent:CreateFontString("questieObjectiveTextString", "ARTWORK", "QuestFont")
        textWrapObjectiveFontString:SetWidth(textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
        textWrapObjectiveFontString:SetHeight(0);
        textWrapObjectiveFontString:SetPoint("LEFT");
        textWrapObjectiveFontString:SetJustifyH("LEFT");
        ---@diagnostic disable-next-line: redundant-parameter
        textWrapObjectiveFontString:SetWordWrap(true)
        textWrapObjectiveFontString:SetVertexColor(1, 1, 1, 1) --Set opacity to 0, even if it is shown it should be invisible
        local font, size = textWrapFrameObject:GetFont()
        --Chinese? "Fonts\\ARKai_T.ttf"
        textWrapObjectiveFontString:SetFont(font, size);
        textWrapObjectiveFontString:Hide()
    end

    if (textWrapObjectiveFontString:IsVisible()) then Questie:Error("TextWrap already running... Please report this on GitHub or Discord.") end

    --Set Defaults
    combineTrailing = combineTrailing or true
    --We show the fontstring and set the text to start the process
    --We have to show it or else the functions won't work... But we set the opacity to 0 on creation
    textWrapObjectiveFontString:SetWidth(desiredWidth or textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
    textWrapObjectiveFontString:Show()

    local useLine = line

    textWrapObjectiveFontString:SetText(useLine)
    --Is the line wrapped?
    if (textWrapObjectiveFontString:GetUnboundedStringWidth() > textWrapObjectiveFontString:GetWrappedWidth()) then
        local lines = {}
        local startIndex = 1
        local endIndex = 2 --We should be able to start at a later index...
        --This function returns a list of size information per row, so we use this to calculate number of rows
        local numberOfRows = #textWrapObjectiveFontString:CalculateScreenAreaFromCharacterSpan(startIndex, strlen(useLine))
        for row = 1, numberOfRows do
            local lastSpaceIndex
            local indexes
            --We use the previous way to get number of rows to loop through characterindex until we get 2 rows
            repeat
                indexes = textWrapObjectiveFontString:CalculateScreenAreaFromCharacterSpan(startIndex, endIndex)
                --Last space of the line to be used to break a new row
                if (string.sub(useLine, endIndex, endIndex) == " ") then
                    lastSpaceIndex = endIndex
                end
                endIndex = endIndex + 1
                --If we are at the end of characters break and set endIndex to strlen
                if (endIndex > strlen(useLine)) then
                    endIndex = strlen(useLine)
                    lastSpaceIndex = endIndex
                    break
                end
            until (#indexes > 1) --Until more than one row

            --Get the line we calculated
            --First to space then endIndex(chinese)
            local newLine = string.sub(useLine, startIndex, lastSpaceIndex or endIndex)

            --This combines a trailing word to the previous line if it is the only word of the line
            --We check lastSpaceIndex here because the logic will be faulty (chinese client)
            if (row == numberOfRows - 1 and combineTrailing and lastSpaceIndex) then
                --Get the last line, in it's full
                local lastLine = string.sub(useLine, endIndex - 2, strlen(useLine))

                --Does the line not contain any space we combine it into the previous line
                if (not string.find(lastLine, " ")) then
                    newLine = string.sub(useLine, startIndex, strlen(useLine))
                    --print("NL1", newLine)
                    table.insert(lines, prefix .. newLine)
                    --Break the for loop on last line, no more running required
                    break
                end
            end
            --Change the startIndex to be the new line, and add the line to the lines list
            startIndex = endIndex - 2
            endIndex = endIndex

            table.insert(lines, prefix .. newLine)
        end
        textWrapObjectiveFontString:Hide()
        return lines
    else
        --Line was not wrapped, return the string as is.
        textWrapObjectiveFontString:Hide()
        useLine = prefix .. line
        return { useLine }
    end
end
