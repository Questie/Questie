---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

local GetAddOnMetadata = QuestieCompat.GetAddOnMetadata

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
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

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

-- Keep Questie's palette while allowing the client to choose the difficulty category.
local difficultyColors = {
    Trivial = {hex = "|cFFC0C0C0", r = 0.753, g = 0.753, b = 0.753},
    Easy = {hex = "|cFF40C040", r = 0.251, g = 0.753, b = 0.251},
    Fair = {hex = "|cFFFFFF00", r = 1, g = 1, b = 0},
    Difficult = {hex = "|cFFFF8040", r = 1, g = 0.502, b = 0.251},
    Impossible = {hex = "|cFFFF1A1A", r = 1, g = 0.102, b = 0.102},
}
local nativeDifficultyColors = {}
if Enum and Enum.RelativeContentDifficulty then
    for name, color in pairs(difficultyColors) do
        nativeDifficultyColors[Enum.RelativeContentDifficulty[name]] = color
    end
end

local function _GetDifficultyColor(level, questId)
    local difficulty = QuestieCompat.GetQuestDifficulty(questId)
    local color = nativeDifficultyColors[difficulty]
    if color then
        -- Prefer the client's quest-specific difficulty; level-based estimates can disagree.
        return color
    end

    -- Use the level estimate when native difficulty is unavailable or unrecognized.
    -- Do not copy Forever's generic GetQuestDifficultyColor: its thresholds differ from the quest-ID API.
    local playerLevel = QuestiePlayer.GetPlayerLevel()
    -- Scaling quests use the player's level for the fallback estimate.
    if level == -1 then level = playerLevel end
    local levelDiff = level - playerLevel

    if levelDiff >= 5 then
        return difficultyColors.Impossible
    elseif levelDiff >= 3 then
        return difficultyColors.Difficult
    elseif levelDiff >= -2 then
        return difficultyColors.Fair
    elseif -levelDiff <= QuestieCompat.GetQuestGreenRange() then
        return difficultyColors.Easy
    else
        return difficultyColors.Trivial
    end
end

---Colors text by difficulty unless event, PvP, or repeatable coloring applies, in that order.
---@param level Level Fallback quest level; -1 uses the player's level.
---@param text string
---@param isRepeatableQuest boolean?
---@param isEventQuest boolean?
---@param isPvPQuest boolean?
---@param questId QuestId? Uses native difficulty on Forever when cached and supported; otherwise uses level.
---@return string
function QuestieLib:PrintDifficultyColor(level, text, isRepeatableQuest, isEventQuest, isPvPQuest, questId)
    if isEventQuest == true then
        return "|cFF6ce314" .. text .. "|r" -- Lime
    end
    if isPvPQuest == true then
        return "|cFFE35639" .. text .. "|r" -- Maroon
    end
    if isRepeatableQuest == true then
        return "|cFF21CCE7" .. text .. "|r" -- Blue
    end

    return _GetDifficultyColor(level, questId).hex .. text .. "|r"
end

---Returns difficulty RGB only; quest-type color overrides belong to PrintDifficultyColor.
---@param level Level Fallback quest level; -1 uses the player's level.
---@param questId QuestId? Uses native difficulty on Forever when cached and supported; otherwise uses level.
---@return number r
---@return number g
---@return number b
function QuestieLib:GetDifficultyColorPercent(level, questId)
    local color = _GetDifficultyColor(level, questId)
    return color.r, color.g, color.b
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
        if float <= .50 then
            return FloatRGBToHex(1, 0 + float * 2, 0)
        else
            return FloatRGBToHex(1.843 - float / 0.593, 1, (float * 2 - 1) * 0.157)
        end
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
    local level, _ = QuestieLib.GetEffectiveQuestLevel(questId);

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

    return QuestieLib:PrintDifficultyColor(level, name, QuestieDB.IsRepeatable(questId),
        QuestieEvent.IsEventQuest(questId), QuestieDB.IsPvPQuest(questId), questId)
end

-- The order of these colors is important for the ColorWheel function.
-- Taken from https://tailwindcolor.com/
---@type Color[]
local colors = {
    -- Light (200)         Standard (500)         -- Family
    {0.99, 0.73, 0.73}, {0.94, 0.19, 0.19}, -- Red
    {0.99, 0.81, 0.59}, {0.98, 0.46, 0.05}, -- Orange
    {0.99, 0.93, 0.54}, {0.92, 0.68, 0.05}, -- Yellow
    {0.73, 0.96, 0.80}, {0.13, 0.77, 0.36}, -- Green
    {0.75, 0.87, 0.99}, {0.23, 0.55, 0.94}, -- Blue
    {0.78, 0.82, 0.99}, {0.39, 0.45, 0.94}, -- Indigo
    {0.87, 0.82, 1.00}, {0.55, 0.35, 0.96}, -- Violet
    {0.99, 0.76, 0.89}, {0.93, 0.16, 0.55}, -- Pink
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
function QuestieLib.GetEffectiveQuestLevel(questId, playerLevel)
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
            l10n("Human"), -- 1
            l10n("Orc"), -- 2
            l10n("Dwarf"), -- 4
            l10n("Night Elf"), -- 8
            l10n("Undead"), -- 16
            l10n("Tauren"), -- 32
            l10n("Gnome"), -- 64
            l10n("Troll"), -- 128
            l10n("Goblin"), -- 256
            l10n("Blood Elf"), -- 512
            l10n("Draenei"), -- 1024
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, -- 2^11 -> 2^20
            l10n("Worgen"), -- 2097152
            nil, -- 2^22
            l10n("Pandaren"), -- 8388608
            l10n("Pandaren") .. spaceString .. l10n("Alliance"), -- 16777216
            l10n("Pandaren") .. spaceString .. l10n("Horde"), -- 33554432
            nil, nil, nil, nil, nil, nil, -- 2^26 -> 2^31
            l10n("High Order Skyborne"), -- 4294967296
            l10n("Windshaper Skyborne"), -- 8589934592
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

-- Some clients (e.g. WoW Forever) don't define RAID_CLASS_COLORS for every class
-- (missing DEATHKNIGHT/MONK); fall back to "" for those rather than erroring.
---@param colorKey string
---@param label string
---@return string?
local function _FormatClass(colorKey, label)
    local color = RAID_CLASS_COLORS[colorKey]
    return color and ("|c" .. color.colorStr .. label .. "|r") or nil
end

---@param classMask number
---@return string
function QuestieLib:GetClassString(classMask)
    if not classMask or classMask == QuestieDB.classKeys.NONE or classMask == QuestieDB.classKeys.ALL_CLASSES then
        return ""
    else
        local classString = ""
        local classTable = QuestieLib:UnpackBinary(classMask)
        local stringTable = {
            _FormatClass("WARRIOR", l10n("Warrior")), -- 1
            _FormatClass("PALADIN", l10n("Paladin")), -- 2
            _FormatClass("HUNTER", l10n("Hunter")), -- 4
            _FormatClass("ROGUE", l10n("Rogue")), -- 8
            _FormatClass("PRIEST", l10n("Priest")), -- 16
            _FormatClass("DEATHKNIGHT", l10n("Death Knight")), -- 32
            _FormatClass("SHAMAN", l10n("Shaman")), -- 64
            _FormatClass("MAGE", l10n("Mage")), -- 128
            _FormatClass("WARLOCK", l10n("Warlock")), -- 256
            _FormatClass("MONK", l10n("Monk")), -- 512
            _FormatClass("DRUID", l10n("Druid")), -- 1024
        }
        local firstRun = true
        for k, v in pairs(classTable) do
            if v and stringTable[k] then
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

---Shared readiness check for the quest cache, objective loaders, startup validation and quest-link tooltips.
---Never modifies the row. Callers own retries, retaining cached data and database fallbacks.
---@param objective QuestObjectiveInfo
---@return boolean readyOrSkippable True allows loading to proceed; it does not imply objective or quest completion.
function QuestieLib.IsObjectiveDataLoaded(objective)
    local text = objective.text
    -- Blizzard sometimes adds permanently empty, unfinished event objectives alongside real objectives.
    -- Waiting for these would never finish. Ignore exact empty strings regardless of type, counts or finished state.
    -- Return true before checking the type, but callers must still omit these rows from their objective lists.
    if text == "" then
        return true
    end
    -- HaveQuestData can be true before individual rows have text or a type. Neither is safe to consume yet.
    -- Missing names leave a leading ASCII space in Classic (" : 0/1") or trailing spaces in Forever ("0/1  ").
    -- Check the original text: trimming whitespace first would erase this evidence of an incomplete client cache.
    if (not text) or (not objective.type) or string.byte(text, 1) == 32 or string.byte(text, -1) == 32 then
        return false
    end
    -- Counters and a suffix can load before the name, leaving text such as "0/15   slain" with no edge spaces.
    -- Parse the client's localized objective format to detect an empty name; never substitute this parsed text for the original.
    if QuestieLib.TrimObjectiveText(text, objective.type) == "" then
        return false
    end
    -- The parser cannot recognize every suffix (e.g. "destroyed"). Treat three consecutive ASCII spaces as a final
    -- missing-name heuristic, independent of language, UTF-8 encoding or word boundaries. This deliberately assumes
    -- legitimate objective text will not contain triple spaces; if it does, it will also be treated as not loaded.
    return not string.find(text, "   ", 1, true)
end

---Synchronously reads Blizzard's cache, including quests outside the local log, and primes missing data.
---Returns nil until all non-empty objective rows are loaded. An empty result is valid, not a quest-completion signal.
---Original objective indices are preserved; the result can have holes. Use index lookup or pairs, not ipairs or #.
---@param questId QuestId
---@return table<ObjectiveIndex, QuestObjectiveInfo>? objectives @Sparse, read-only rows; iterate with pairs only, never ipairs or #.
function QuestieLib.GetLoadedQuestObjectives(questId)
    local haveQuestData = HaveQuestData(questId)
    -- Query even when quest data is missing: this also requests objective data from the client.
    local objectives = C_QuestLog.GetQuestObjectives(questId)
    if (not haveQuestData) or (not objectives) then
        return nil
    end
    local loadedObjectives = {}
    for index, objective in ipairs(objectives) do
        if not QuestieLib.IsObjectiveDataLoaded(objective) then
            return nil
        end
        -- Empty client placeholders do not block loading and are not display objectives.
        if objective.text ~= "" then
            loadedObjectives[index] = objective
        end
    end
    return loadedObjectives
end

---Polls up to 20 times. Even cache hits are delivered asynchronously on a ticker resume.
---Calls onSuccess once when all non-empty rows are ready, or onFailure on timeout. Cancellation calls neither.
---Empty-text rows are skipped by GetLoadedQuestObjectives, so they cannot force a timeout.
---Use GetLoadedQuestObjectives when the caller needs a synchronous result.
---@param questId QuestId
---@param onSuccess fun(objectives: table<ObjectiveIndex, QuestObjectiveInfo>) @Sparse, read-only objectives; iterate with pairs only.
---Do not use ipairs or # on the callback's objective table; original indices can have holes.
---@param onFailure? fun() @Optional callback when load times out
---@param tickSpeed? number @Optional, defaults to 0.2 seconds
---@return Ticker timer @Call timer:Cancel() to stop loading
---@return thread thread
function QuestieLib.ContinueOnQuestObjectivesLoad(questId, onSuccess, onFailure, tickSpeed)
    return ThreadLib.Thread(function()
        for attempt = 1, 20 do
            local objectives = QuestieLib.GetLoadedQuestObjectives(questId)
            if objectives then
                onSuccess(objectives)
                return
            end
            if attempt < 20 then
                coroutine.yield()
            end
        end
        if onFailure then
            onFailure()
        end
    end, tickSpeed or 0.2)
end

-- Name-only repair rows for Items the client loaded because the composed database lacked them.
-- This table is the RuntimeItemRepair slot's full replacement rows: repairs accumulate across
-- quests, and the whole table is published once per frame after any new repair.
---@type table<ItemId, table<integer, string>>
local repairedItemNames = {}

-- True from the first new repair in a frame until the deferred publish runs, so every client
-- callback that lands in the same frame (the already-cached Items of the login quest log fire
-- synchronously, in one burst) shares one provider write.
local repairPublishPending = false

---Publishes the accumulated repairs on the next frame unless a publish is already scheduled.
---@return nil
local function _ScheduleRepairPublish()
    if repairPublishPending then
        return
    end
    repairPublishPending = true
    C_Timer.After(0, function()
        repairPublishPending = false
        QuestieCorrections.SetCorrection("Item", "RuntimeItemRepair", repairedItemNames)
    end)
end

---Asks the client for the names of objective Items the composed database lacks and repairs each one
---through the name-only RuntimeItemRepair Policy Correction slot when the asynchronous load completes.
---Runs on quest accept and for every quest already in the log at login.
---@param questId QuestId
---@return nil
function QuestieLib.RepairMissingItemNames(questId)
    local quest = QuestieDB.GetQuest(questId)
    if not (quest and quest.ObjectiveData) then
        return
    end

    for _, objective in pairs(quest.ObjectiveData) do
        if objective.Type == "item" and not QuestieDB.ItemPointers[objective.Id] then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieLib.RepairMissingItemNames] Requesting client data for missing itemId:",
                objective.Id)
            local item = Item:CreateFromItemID(objective.Id)
            item:ContinueOnItemLoad(function()
                ---Records one client-loaded Item name and schedules the RuntimeItemRepair publish so the Item
                ---becomes readable and enumerable. A repeated callback with an unchanged name is a no-op and a
                ---nil name is ignored. Name only: no relationship field is inferred.
                local itemName = item:GetItemName()
                if not itemName then
                    return
                end

                local nameKey = QuestieDB.itemKeys.name
                local existingRepair = repairedItemNames[objective.Id]
                if existingRepair and existingRepair[nameKey] == itemName then
                    return
                end

                repairedItemNames[objective.Id] = {[nameKey] = itemName}
                _ScheduleRepairPublish()
            end)
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
        local questLevel, _ = QuestieLib.GetEffectiveQuestLevel(questId)
        local suffix = QuestieLib:GetQuestTypeSuffix(questId)
        tinsert(sortedQuestsByLevel, {questLevel or 0, questId, suffix})
    end
    table.sort(sortedQuestsByLevel, compareQuestsByLevelAndType)

    return sortedQuestsByLevel
end

function QuestieLib:UnpackBinary(val)
    local ret = {}
    for q = 0, 33 do
        if math.floor(val / (2 ^ q)) % 2 == 1 then
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

    Questie.db.global.lastKnownDailyReset[realmName] = GetServerTime() + QuestieCompat.GetQuestResetTime()
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
        return date("%Y년 " .. monthName .. " %d일" .. " " .. weekDay .. " %H:%M", timeStamp)
    elseif langCode == "ptBR" then
        return date(weekDay .. ", %d de " .. monthName .. " de %Y às %H:%M", timeStamp)
    elseif langCode == "ruRU" then
        return date(weekDay .. ", %d " .. monthName .. " %Y, %H:%M", timeStamp)
    elseif langCode == "zhCN" or langCode == "zhTW" then
        return date("%Y年" .. monthName .. "%d日 " .. weekDay .. " %H:%M", timeStamp)
    end

    return date(weekDay .. ", " .. monthName .. " %d, %Y at %H:%M", timeStamp)
end

---Replaces a recognized native progress counter without rewriting its wording or placement.
---Returns nil for unrecognized layouts so callers can retain their existing remote-progress fallback.
---@param nativeText string?
---@param fulfilled number?
---@param required number?
---@return string?
function QuestieLib.ReplaceObjectiveTextProgress(nativeText, fulfilled, required)
    if type(nativeText) ~= "string" or type(fulfilled) ~= "number" or type(required) ~= "number" then
        return nil
    end

    -- Try both client layouts, regardless of client version. Anchors avoid replacing fractions inside instructions.
    local suffix = nativeText:match("^%d+/%d+(%s+.+)$")
    if suffix then
        return fulfilled .. "/" .. required .. suffix
    end
    local prefix = nativeText:match("^(.+:%s*)%d+/%d+$") or nativeText:match("^(.+：%s*)%d+/%d+$")
    if prefix then
        return prefix .. fulfilled .. "/" .. required
    end
    return nil
end

---Returns full wording without trailing progress numbers, independently of display settings.
---For example, "Wolf slain: 0/1" becomes "Wolf slain".
---@param rawObjectiveText string
---@return string? description @Nil if no trailing progress counter matches
function QuestieLib.GetFullObjectiveText(rawObjectiveText)
    -- This supports three different input syntax:
    -- Classic clients: "Wolf slain: 0/1"
    -- Chinese Classic clients: "Wolf slain： 0/1" (full-width colon)
    -- Forever clients: "0/1 Wolf slain"
    return string.match(rawObjectiveText, "^(.*):%s*%d+/%d+$") or string.match(rawObjectiveText, "^(.*)：%s*%d+/%d+$") or string.match(rawObjectiveText, "^%d+/%d+%s*(.*)$")
end

---Populates optional FullDescription fields only when full wording is enabled in the profile.
---Use GetFullObjectiveText instead for extraction that must not depend on display settings.
---For example, "Wolf slain: 0/1" becomes "Wolf slain".
---@param rawObjectiveText string
---@return string? description @Nil when trimObjectiveText is enabled or no trailing counter matches
function QuestieLib.GetFullObjectiveTextConditional(rawObjectiveText)
    if Questie.db.profile.trimObjectiveText then
        return nil
    end
    return QuestieLib.GetFullObjectiveText(rawObjectiveText)
end
