---@class QuestieDB : QuestieModule
local QuestieDB = QuestieLoader:CreateModule("QuestieDB")
---@class QuestieDBPrivate
local _QuestieDB = QuestieDB.private

-------------------------
--Import modules.
-------------------------
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type DBCompiler
local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieQuestPrivate
local _QuestieQuest = QuestieQuest.private

--- A list of quests that will never be available, used to quickly skip quests.
---@alias AutoBlacklistString "rep"|"skill"|"race"|"class"
---@type table<number, AutoBlacklistString>
QuestieDB.autoBlacklist = {}

local tinsert, tremove, next = table.insert, table.remove, next
local bitband = bit.band

-- questFlags https://github.com/cmangos/issues/wiki/Quest_template#questflags
local QUEST_FLAGS_DAILY = 4096
local QUEST_FLAGS_WEEKLY = 32768
-- Pre calculated 2 * QUEST_FLAGS, for testing a bit flag
local QUEST_FLAGS_DAILY_X2 = 2 * QUEST_FLAGS_DAILY
local QUEST_FLAGS_WEEKLY_X2 = 2 * QUEST_FLAGS_WEEKLY

---@enum QuestTagIds
QuestieDB.questTagIds = {
    ELITE = 1,
    CLASS = 21,
    PVP = 41,
    RAID = 62,
    DUNGEON = 81,
    LEGENDARY = 83,
    HEROIC = 85,
    RAID_10 = 88,
    RAID_25 = 89,
    SCENARIO = 98,
    ACCOUNT = 102,
    CELESTIAL = 294,
}

-- * race bitmask data, for easy access
-- ? The PlayableRaceBit can be found in ChrRaces.dbc
-- ? https://wago.tools/db2/ChrRaces?build=5.5.0.60802&filter[PlayableRaceBit]=>-1
-- ? The values below are calculated by 2^PlayableRaceBit
---@class RaceKeys
QuestieDB.raceKeys = {
    -- Allow all alliance races
    ALL_ALLIANCE = (function()
        if Questie.IsClassic then
            return 77
        elseif Questie.IsTBC or Questie.IsWotlk then
            return 1101
        elseif Questie.IsCata then
            return 2098253
        elseif Questie.IsMoP then
            return 18875469
        else
            print("Unknown expansion for ALL_ALLIANCE")
            return 77
        end
    end)(),
    -- ALlow all horde races
    ALL_HORDE = (function()
        if Questie.IsClassic then
            return 178
        elseif Questie.IsTBC or Questie.IsWotlk then
            return 690
        elseif Questie.IsCata then
            return 946
        elseif Questie.IsMoP then
            return 33555378
        else
            print("Unknown expansion for ALL_HORDE")
            return 178
        end
    end)(),
    -- Allow all races (No limit on allowed races)
    NONE = 0,

    --[[PlayableRaceBit]]
    --[[ 0]] HUMAN = 1,
    --[[ 1]] ORC  = 2,
    --[[ 2]] DWARF = 4,
    --[[ 3]] NIGHT_ELF = 8,
    --[[ 4]] UNDEAD = 16,
    --[[ 5]] TAUREN = 32,
    --[[ 6]] GNOME = 64,
    --[[ 7]] TROLL = 128,
    --[[ 8]] GOBLIN = 256,                  -- Cata
    --[[ 9]] BLOOD_ELF = 512,               -- TBC
    --[[10]] DRAENEI = 1024,                -- TBC
    --[[21]] WORGEN = 2097152,              -- Cata
    --[[23]] PANDAREN = 8388608,            -- MoP
    --[[24]] PANDAREN_ALLIANCE = 16777216,  -- MoP
    --[[25]] PANDAREN_HORDE = 33554432,     -- MoP
}

-- Combining these with "and" makes the order matter
-- 1 and 2 ~= 2 and 1
QuestieDB.classKeys = {
    NONE = 0,

    WARRIOR = 1,
    PALADIN = 2,
    HUNTER = 4,
    ROGUE = 8,
    PRIEST = 16,
    DEATH_KNIGHT = 32,
    SHAMAN = 64,
    MAGE = 128,
    WARLOCK = 256,
    MONK = 512,
    DRUID = 1024
}

QuestieDB.specialFlags = {
    NONE = 0,
    REPEATABLE = 1,
}

_QuestieDB.questCache = {}; -- stores quest objects so they dont need to be regenerated
_QuestieDB.itemCache = {};
_QuestieDB.npcCache = {};
_QuestieDB.objectCache = {};
_QuestieDB.zoneCache = {};

---A Memoized table for function Quest:CheckRace
---
---Usage: checkRace[requiredRaces]
---@type table<number, boolean>
local checkRace
---A Memoized table for function Quest:CheckClass
---
---Usage: checkRace[requiredClasses]
---@type table<number, boolean>
local checkClass

---QuestieCorrections.hiddenQuests
local QuestieCorrectionshiddenQuests
---Questie.db.char.hidden
local Questiedbcharhidden

QuestieDB.itemDataOverrides = {}
QuestieDB.npcDataOverrides = {}
QuestieDB.objectDataOverrides = {}
QuestieDB.questDataOverrides = {}

local QuestDB

QuestieDB.activeChildQuests = {}


function QuestieDB:Initialize()

    StaticPopupDialogs["QUESTIE_DATABASE_ERROR"] = { -- /run StaticPopup_Show ("QUESTIE_DATABASE_ERROR")
        text = l10n("There was a problem initializing Questie's database. This can usually be fixed by recompiling the database."),
        button1 = l10n("Recompile Database"),
        button2 = l10n("Don't show again"),
        OnAccept = function()
            if Questie.IsSoD then
                Questie.db.global.sod.dbIsCompiled = false
            else
                Questie.db.global.dbIsCompiled = false
            end
            ReloadUI()
        end,
        OnDecline = function()
            Questie.db.profile.disableDatabaseWarnings = true
        end,
        OnShow = function(self)
            self:SetFrameStrata("TOOLTIP")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3
    }

    _QuestieDB.InitializeQuestTagInfoCorrections()

    -- For now we store both, the SoD database and the Era/HC database
    local npcBin, npcPtrs, questBin, questPtrs, objBin, objPtrs, itemBin, itemPtrs
    if Questie.IsSoD then
        npcBin = Questie.db.global.sod.npcBin
        npcPtrs = Questie.db.global.sod.npcPtrs
        questBin = Questie.db.global.sod.questBin
        questPtrs = Questie.db.global.sod.questPtrs
        objBin = Questie.db.global.sod.objBin
        objPtrs = Questie.db.global.sod.objPtrs
        itemBin = Questie.db.global.sod.itemBin
        itemPtrs = Questie.db.global.sod.itemPtrs
    else
        npcBin = Questie.db.global.npcBin
        npcPtrs = Questie.db.global.npcPtrs
        questBin = Questie.db.global.questBin
        questPtrs = Questie.db.global.questPtrs
        objBin = Questie.db.global.objBin
        objPtrs = Questie.db.global.objPtrs
        itemBin = Questie.db.global.itemBin
        itemPtrs = Questie.db.global.itemPtrs
    end

    QuestieDB.QueryNPC = QuestieDBCompiler:GetDBHandle(npcBin, npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder), QuestieDB.npcKeys, QuestieDB.npcDataOverrides)
    QuestieDB.QueryQuest = QuestieDBCompiler:GetDBHandle(questBin, questPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder), QuestieDB.questKeys, QuestieDB.questDataOverrides)
    QuestieDB.QueryObject = QuestieDBCompiler:GetDBHandle(objBin, objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder), QuestieDB.objectKeys, QuestieDB.objectDataOverrides)
    QuestieDB.QueryItem = QuestieDBCompiler:GetDBHandle(itemBin, itemPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder), QuestieDB.itemKeys, QuestieDB.itemDataOverrides)

    --[[
/run local q = Questie.db.global; q.npcBin=nil; q.questBin=nil; q.objBin=nil; q.itemBin=nil; q.npcPtrs=nil; q.questPtrs=nil; q.objPtrs=nil; q.itemPtrs=nil; q.sod=nil
/dump Questie.db.global
    ]]

    QuestieDB._QueryQuestSingle = QuestieDB.QueryQuest.QuerySingle
    QuestieDB._QueryNPCSingle = QuestieDB.QueryNPC.QuerySingle
    QuestieDB._QueryObjectSingle = QuestieDB.QueryObject.QuerySingle
    QuestieDB._QueryItemSingle = QuestieDB.QueryItem.QuerySingle

    QuestieDB.NPCPointers = QuestieDB.QueryNPC.pointers
    QuestieDB.QuestPointers = QuestieDB.QueryQuest.pointers
    QuestieDB.ObjectPointers = QuestieDB.QueryObject.pointers
    QuestieDB.ItemPointers = QuestieDB.QueryItem.pointers

    QuestieDB._QueryNPC = QuestieDB.QueryNPC.Query
    QuestieDB._QueryQuest = QuestieDB.QueryQuest.Query
    QuestieDB._QueryObject = QuestieDB.QueryObject.Query
    QuestieDB._QueryItem = QuestieDB.QueryItem.Query

    ---@diagnostic disable-next-line: undefined-global
    assert(type(LibQuestieDB) == "function", "LibQuestieDB is not loaded, Questie requires the addon QuestieDB!")
    local LibQuestieDB = QuestieDB.LibQuestieDB
    local quest, npc, object, item               = LibQuestieDB.Quest, LibQuestieDB.Npc, LibQuestieDB.Object, LibQuestieDB.Item
    QuestDB = LibQuestieDB.Quest
    assert(type(quest) == "table", "LibQuestieDB.Quest is not a table!")
    assert(type(npc) == "table", "LibQuestieDB.Npc is not a table!")
    assert(type(object) == "table", "LibQuestieDB.Object is not a table!")
    assert(type(item) == "table", "LibQuestieDB.Item is not a table!")

    local QueryQuestReplaceFunction = function(id, tbl)
        local retTable = {}
        for i=1, #tbl do
            local value = tbl[i]
            if quest[value] then
                retTable[i] = quest[value](id)
                -- retTable[i] = quest[value](id) or 1337
                -- if retTable[i] == 1337 then
                --     retTable[i] = nil
                -- end
            end
        end
        return retTable
    end
    local QueryNPCReplaceFunction = function(id, tbl)
        local retTable = {}
        for i = 1, #tbl do
            local value = tbl[i]
            if npc[value] then
                retTable[i] = npc[value](id)
                -- retTable[i] = npc[value](id) or 1337
                -- if retTable[i] == 1337 then
                --     retTable[i] = nil
                -- end
            end
        end
        return retTable
    end
    local QueryObjectReplaceFunction = function(id, tbl)
        local retTable = {}
        for i = 1, #tbl do
            local value = tbl[i]
            if object[value] then
                retTable[i] = object[value](id)
                -- retTable[i] = object[value](id) or 1337
                -- if retTable[i] == 1337 then
                --     retTable[i] = nil
                -- end
            end
        end
        return retTable
    end
    local QueryItemReplaceFunction = function(id, tbl)
        local retTable = {}
        for i = 1, #tbl do
            local value = tbl[i]
            if item[value] then
                retTable[i] = item[value](id)
                -- retTable[i] = item[value](id) or 1337
                -- if retTable[i] == 1337 then
                --     retTable[i] = nil
                -- end
            end
        end
        return retTable
    end


    -- QuestieDB.QueryNPC = QuestieDB._QueryNPC
    -- QuestieDB.QueryQuest = QuestieDB._QueryQuest
    -- QuestieDB.QueryObject = QuestieDB._QueryObject
    -- QuestieDB.QueryItem = QuestieDB._QueryItem

    QuestieDB.QueryNPC = QueryNPCReplaceFunction
    QuestieDB.QueryQuest = QueryQuestReplaceFunction
    QuestieDB.QueryObject = QueryObjectReplaceFunction
    QuestieDB.QueryItem = QueryItemReplaceFunction
    -- QuestieDB.QQueryNPC = QueryNPCReplaceFunction
    -- QuestieDB.QQueryQuest = QueryQuestReplaceFunction
    -- QuestieDB.QQueryObject = QueryObjectReplaceFunction
    -- QuestieDB.QQueryItem = QueryItemReplaceFunction
    --[[
    /dump QuestieDB.QueryQuest(12, QuestieDB._questAdapterQueryOrder)
    /dump QuestieDB.QQueryQuest(12, QuestieDB._questAdapterQueryOrder)
    /dump QuestieDB.QueryObject(276, QuestieDB._objectAdapterQueryOrder)
    /dump QuestieDB.QQueryObject(276, QuestieDB._objectAdapterQueryOrder)
    /dump QuestieDB.QueryItem(25, QuestieDB._itemAdapterQueryOrder)
    /dump QuestieDB.QQueryItem(25, QuestieDB._itemAdapterQueryOrder)
    ]]

    local QueryQuestSingleReplaceFunction        = function(id, value)
        if quest[value] then
            return quest[value](id)
        end
        return nil
    end
    local QueryNPCSingleReplaceFunction          = function(id, value)
        if npc[value] then
            return npc[value](id)
        end
        return nil
    end
    local QueryObjectSingleReplaceFunction       = function(id, value)
        if object[value] then
            return object[value](id)
        end
        return nil
    end
    local QueryItemSingleReplaceFunction         = function(id, value)
        if item[value] then
            return item[value](id)
        end
        return nil
    end

    -- QuestieDB.QueryQuestSingle                   = QuestieDB._QueryQuestSingle
    -- QuestieDB.QueryNPCSingle                     = QuestieDB._QueryNPCSingle
    -- QuestieDB.QueryObjectSingle                  = QuestieDB._QueryObjectSingle
    -- QuestieDB.QueryItemSingle                    = QuestieDB._QueryItemSingle

    QuestieDB.QueryQuestSingle                   = QueryQuestSingleReplaceFunction
    QuestieDB.QueryNPCSingle                     = QueryNPCSingleReplaceFunction
    QuestieDB.QueryObjectSingle                  = QueryObjectSingleReplaceFunction
    QuestieDB.QueryItemSingle                    = QueryItemSingleReplaceFunction

    -- data has been corrected, ensure cache is empty (something might have accessed the api before questie initialized)
    _QuestieDB.questCache = {};
    _QuestieDB.itemCache = {};
    _QuestieDB.npcCache = {};
    _QuestieDB.objectCache = {};
    _QuestieDB.zoneCache = {};

    --? This improves performance a lot, the regular functions still work but this is much faster because i caches
    checkRace  = QuestieLib:TableMemoizeFunction(QuestiePlayer.HasRequiredRace)
    checkClass = QuestieLib:TableMemoizeFunction(QuestiePlayer.HasRequiredClass)
    --? Set the localized versions of these.
    QuestieCorrectionshiddenQuests = QuestieCorrections.hiddenQuests
    Questiedbcharhidden = Questie.db.char.hidden
end

---@param objectId ObjectId
---@return Object|nil
function QuestieDB:GetObject(objectId)
    if not objectId then
        return nil
    end
    if _QuestieDB.objectCache[objectId] then
        return _QuestieDB.objectCache[objectId];
    end

    --local rawdata = QuestieDB.objectData[objectId];
    local rawdata = QuestieDB.QueryObject(objectId, QuestieDB._objectAdapterQueryOrder)

    if not rawdata then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetObject] rawdata is nil for objectID:", objectId)
        return nil
    end

    local obj = {
        id = objectId,
        type = "object"
    }

    for stringKey, intKey in pairs(QuestieDB.objectKeys) do
        obj[stringKey] = rawdata[intKey]
    end
    --_QuestieDB.objectCache[objectId] = obj;
    return obj;
end

---@param itemId ItemId
---@return Item|nil
function QuestieDB:GetItem(itemId)
    if (not itemId) or (itemId == 0) then
        return nil
    end
    if _QuestieDB.itemCache[itemId] then
        return _QuestieDB.itemCache[itemId];
    end

    local rawdata = QuestieDB.QueryItem(itemId, QuestieDB._itemAdapterQueryOrder)

    if not rawdata then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetItem] rawdata is nil for itemID:", itemId)
        return nil
    end

    local item = {
        Id = itemId,
        Sources = {},
        Hidden = QuestieCorrections.questItemBlacklist[itemId]
    }

    for stringKey, intKey in pairs(QuestieDB.itemKeys) do
        item[stringKey] = rawdata[intKey]
    end

    local sources = item.Sources

    if rawdata[QuestieDB.itemKeys.npcDrops] then
        for _, npcId in pairs(rawdata[QuestieDB.itemKeys.npcDrops]) do
            sources[#sources+1] = {
                Id = npcId,
                Type = "monster",
            }
        end
    end

    if rawdata[QuestieDB.itemKeys.vendors] then
        for _, npcId in pairs(rawdata[QuestieDB.itemKeys.vendors]) do
            sources[#sources+1] = {
                Id = npcId,
                Type = "monster",
            }
        end
    end

    if rawdata[QuestieDB.itemKeys.objectDrops] then
        for _, v in pairs(rawdata[QuestieDB.itemKeys.objectDrops]) do
            sources[#sources+1] = {
                Id = v,
                Type = "object",
            }
        end
    end

    return item
end

---@param questId number
---@return boolean
function QuestieDB.IsRepeatable(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "specialFlags")
    return flags and bitband(flags, 1) ~= 0
end

---@param questId number
---@return boolean
function QuestieDB.IsDailyQuest(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "questFlags")
    -- test a bit flag: (value % (2*flag) >= flag)
    return flags and (flags % QUEST_FLAGS_DAILY_X2) >= QUEST_FLAGS_DAILY
end

---@param questId number
---@return boolean
function QuestieDB.IsWeeklyQuest(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "questFlags")
    -- test a bit flag: (value % (2*flag) >= flag)
    return flags and (flags % QUEST_FLAGS_WEEKLY_X2) >= QUEST_FLAGS_WEEKLY
end

---@param questId number
---@return boolean
function QuestieDB.IsCelestialQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.CELESTIAL
end

---@param questId number
---@return boolean
function QuestieDB.IsAccountQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.ACCOUNT
end

---@param questId number
---@return boolean
function QuestieDB.IsScenarioQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.SCENARIO
end

---@param questId number
---@return boolean
function QuestieDB.IsHeroicQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.HEROIC
end

---@param questId number
---@return boolean
function QuestieDB.IsLegendaryQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.LEGENDARY
end

---@param questId number
---@return boolean
function QuestieDB.IsDungeonQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.DUNGEON
end

---@param questId number
---@return boolean
function QuestieDB.IsRaidQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.RAID or questTagId == QuestieDB.questTagIds.RAID_10 or questTagId == QuestieDB.questTagIds.RAID_25
end

---@param questId number
---@return boolean
function QuestieDB.IsPvPQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.PVP
end

---@param questId number
---@return boolean
function QuestieDB.IsGroupQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.ELITE
end

--[[ Commented out because not used anywhere
---@param questId number
---@return boolean
function QuestieDB:IsAQWarEffortQuest(questId)
    return QuestieQuestBlacklist.AQWarEffortQuests[questId]
end
]]--

---@param class string
---@return number
function QuestieDB:GetZoneOrSortForClass(class)
    return QuestieDB.sortKeys[class]
end

local questTagInfoCache = {}

--- Wrapper function for the GetQuestTagInfo API to correct
--- quests that are falsely marked by Blizzard and cache the results.
---@param questId number
---@return number|nil questTagId
---@return string|nil questTagName
function QuestieDB.GetQuestTagInfo(questId)
    if questTagInfoCache[questId] then
        return questTagInfoCache[questId][1], questTagInfoCache[questId][2]
    end

    local questTagCorrections = _QuestieDB.questTagCorrections
    local questTagId, questTagName
    if questTagCorrections[questId] then
        questTagId, questTagName = questTagCorrections[questId][1], questTagCorrections[questId][2]
    else
        questTagId, questTagName = GetQuestTagInfo(questId)
    end

    -- cache the result to avoid hitting the API throttling limit
    questTagInfoCache[questId] = {questTagId, questTagName}

    return questTagId, questTagName
end

---@param questId number
---@return boolean
function QuestieDB.IsActiveEventQuest(questId)
    --! If you edit the logic here, also edit in AvailableQuests.IsLevelRequirementsFulfilled
    return QuestieEvent.activeQuests[questId] == true
end

---@param exclusiveTo table<number, number>
---@return boolean
function QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)
    if (not exclusiveTo) then
        return false
    end

    for _, exId in pairs(exclusiveTo) do
        if Questie.db.char.complete[exId] then
            return true
        end
    end
    return false
end

---@param preQuestGroup table<number, number>
---@return boolean
function QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
    if (not preQuestGroup) or (not next(preQuestGroup)) then
        return true
    end
    for preQuestIndex=1, #preQuestGroup do
        local preQuestId = preQuestGroup[preQuestIndex]
        if preQuestId < 0 then
            -- Negative entries in preQuestGroup skip the exclusiveTo check
            if (not Questie.db.char.complete[-preQuestId]) then
                return false
            end
        -- If a quest is not complete and no exclusive quest is complete, the requirement is not fulfilled
        elseif not Questie.db.char.complete[preQuestId] then
            local preQuest = QuestieDB.QueryQuestSingle(preQuestId, "exclusiveTo")
            if (not preQuest) then
                return false
            end

            local anyExclusiveFinished = false
            for i=1, #preQuest do
                if Questie.db.char.complete[preQuest[i]] then
                    anyExclusiveFinished = true
                end
            end
            if not anyExclusiveFinished then
                return false
            end
        end
    end
    -- All preQuests are complete
    return true
end

---@param preQuestSingle number[]
---@return boolean
function QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
    if (not preQuestSingle) or (not next(preQuestSingle)) then
        return true
    end
    for preQuestIndex=1, #preQuestSingle do
        -- If a quest is complete the requirement is fulfilled
        if Questie.db.char.complete[preQuestSingle[preQuestIndex]] then
            return true
        end
    end
    -- No preQuest is complete
    return false
end

---@param questId number
---@param debugPrint boolean? -- if true, IsDoable will print conclusions to debug channel
---@return boolean
function QuestieDB.IsDoable(questId, debugPrint)

    --!  Before changing any logic in QuestieDB.IsDoable, make sure
    --!  to mirror the same logic to QuestieDB.IsDoableVerbose!

    -- IsDoable determines if the player is currently eligible for
    -- a quest, and returns that result as true/false in order to
    -- programmatically show/hide quests and determine further logic.

    -- IsDoableVerbose does the same logic, but returns human-readable
    -- explanations as a string for display in the UI.

    -- These functions are maintained separately for performance,
    -- because IsDoable is often called in a loop through every
    -- quest in the DB in order to update icons, while
    -- IsDoableVerbose is only called manually by the user.

    local completedQuests = Questie.db.char.complete
    local currentQuestlog = QuestiePlayer.currentQuestlog

    -- These are localized in the init function
    if completedQuests[questId] then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is already finished!") end
        return false
    end

    if QuestieCorrectionshiddenQuests[questId] then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is hidden automatically!") end
        return false
    end

    if Questiedbcharhidden[questId] then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is hidden manually!") end
        return false
    end

    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")
    if (requiredRaces and not checkRace[requiredRaces]) then
        QuestieDB.autoBlacklist[questId] = "race"
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Race requirement not fulfilled for quest " .. questId) end
        return false
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle then
        local isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
        if not isPreQuestSingleFulfilled then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Pre-quest requirement not fulfilled for quest " .. questId) end
            return false
        end
    end

    local requiredClasses = QuestieDB.QueryQuestSingle(questId, "requiredClasses")
    if (requiredClasses and not checkClass[requiredClasses]) then
        QuestieDB.autoBlacklist[questId] = "class"
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Class requirement not fulfilled for quest " .. questId) end
        return false
    end

    local requiredMinRep = QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    local requiredMaxRep = QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")
    if (requiredMinRep or requiredMaxRep) then
        local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)
        if (not ((aboveMinRep and hasMinFaction) and (belowMaxRep and hasMaxFaction))) then
            --- If we haven't got the faction for min or max we blacklist it
            if not hasMinFaction or not hasMaxFaction then -- or not belowMaxRep -- This is something we could have done, but would break if you rep downwards
                QuestieDB.autoBlacklist[questId] = "rep"
            end

            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet reputation requirements for quest " .. questId) end
            return false
        end
    end

    local requiredSkill = QuestieDB.QueryQuestSingle(questId, "requiredSkill")
    if (requiredSkill) then
        local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
        if (not (hasProfession and hasSkillLevel)) then
            --? We haven't got the profession so we blacklist it.
            if(not hasProfession) then
                QuestieDB.autoBlacklist[questId] = "skill"
            end

            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet profession requirements for quest " .. questId) end
            return false
        end
    end

    --? PreQuestGroup and PreQuestSingle are mutualy exclusive to eachother and preQuestSingle is more prevalent
    --? Only try group if single does not exist.
    if not preQuestSingle then
        -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
        local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
        if preQuestGroup then
            local isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
            if not isPreQuestGroupFulfilled then
                if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Group pre-quest requirement not fulfilled for quest " .. questId) end
                return false
            end
        end
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest and parentQuest ~= 0 then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " has an inactive parent quest") end
        return false
    end

    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    if nextQuestInChain and nextQuestInChain ~= 0 then
        if completedQuests[nextQuestInChain] or currentQuestlog[nextQuestInChain] then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Follow up quests already completed or in the quest log for quest " .. questId) end
            return false
        end
    end

    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    local ExclusiveQuestGroup = QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
    if ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for _, v in pairs(ExclusiveQuestGroup) do
            if completedQuests[v] or currentQuestlog[v] then
                if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player has completed a quest exclusive with quest " .. questId) end
                return false
            end
        end
    end

    if (not DailyQuests:IsActiveDailyQuest(questId)) then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is a daily quest which isn't active today!") end
        return false
    end

    local requiredSpecialization = QuestieDB.QueryQuestSingle(questId, "requiredSpecialization")
    if (requiredSpecialization) and (requiredSpecialization > 0) then
        local hasSpecialization = QuestieProfessions:HasSpecialization(requiredSpecialization)
        if (not hasSpecialization) then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet profession specialization requirements for quest " .. questId) end
            return false
        end
    end

    local requiredSpell = QuestieDB.QueryQuestSingle(questId, "requiredSpell")
    if (requiredSpell) and (requiredSpell ~= 0) then
        local hasSpell = IsSpellKnownOrOverridesKnown(math.abs(requiredSpell))
        local hasProfSpell = IsPlayerSpell(math.abs(requiredSpell))
        if (requiredSpell > 0) and (not hasSpell) and (not hasProfSpell) then -- if requiredSpell is positive, we make the quest ineligible if the player does NOT have the spell
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet learned spell requirements for quest " .. questId) end
            return false
        elseif (requiredSpell < 0) and (hasSpell or hasProfSpell) then -- if requiredSpell is negative, we make the quest ineligible if the player DOES have the spell
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet not learned spell requirements for quest " .. questId) end
            return false
        end
    end

    -- Check and see if the Quest requires an achievement before showing as available
    if _QuestieDB:CheckAchievementRequirements(questId) == false then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet achievement requirements for quest " .. questId) end
        return false
    end

    -- Check if this quest is a breadcrumb
    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(questId, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
        -- Check the target quest of this breadcrumb
        if completedQuests[breadcrumbForQuestId] or currentQuestlog[breadcrumbForQuestId] then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Target of breadcrumb quest already completed or in the quest log for quest " .. questId) end
            return false
        end
        -- Check if the other breadcrumbs are active
        local otherBreadcrumbs = QuestieDB.QueryQuestSingle(breadcrumbForQuestId, "breadcrumbs")
        for _, breadcrumbId in ipairs(otherBreadcrumbs or {}) do -- TODO: Remove `or {}` when we have a validation for the breadcrumb data
            if breadcrumbId ~= questId and currentQuestlog[breadcrumbId] then
                if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Alternative breadcrumb quest in the quest log for quest " .. questId) end
                return false
            end
        end
    end

    -- Check if this quest has active breadcrumbs
    local breadcrumbs = QuestieDB.QueryQuestSingle(questId, "breadcrumbs")
    if breadcrumbs then
        for _, breadcrumbId in ipairs(breadcrumbs) do
            if QuestiePlayer.currentQuestlog[breadcrumbId] then
                if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Breadcrumb quest in the quest log for quest " .. questId) end
                return false
            end
        end
    end

    if DailyQuests.ShouldBeHidden(questId, completedQuests, currentQuestlog) then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Daily quest " .. questId .. " is not active") end
        return false
    end

    return true
end

---@param questId number
---@param debugPrint boolean? -- if true, IsDoable will print conclusions to debug channel
---@param returnText boolean? -- if true, IsDoable will return plaintext explanation instead of true/false
---@param returnBrief boolean? -- if true and returnText is true, IsDoable will return a very brief explanation instead of a verbose one
---@return string
function QuestieDB.IsDoableVerbose(questId, debugPrint, returnText, returnBrief)

    --!  Before changing any logic in QuestieDB.IsDoable, make sure
    --!  to mirror the same logic to QuestieDB.IsDoableVerbose!

    -- IsDoable determines if the player is currently eligible for
    -- a quest, and returns that result as true/false in order to
    -- programmatically show/hide quests and determine further logic.

    -- IsDoableVerbose does the same logic, but returns human-readable
    -- explanations as a string for display in the UI.

    -- These functions are maintained separately for performance,
    -- because IsDoable is often called in a loop through every
    -- quest in the DB in order to update icons, while
    -- IsDoableVerbose is only called manually by the user.

    local completedQuests = Questie.db.char.complete
    local currentQuestlog = QuestiePlayer.currentQuestlog

    if completedQuests[questId] then
        if returnText and returnBrief then
            return "Ineligible: Already complete"
        elseif returnText then
            return "Player has already completed quest " .. questId .. "!"
        end
    end

    if C_QuestLog.IsOnQuest(questId) == true then
        local msg = "Quest " .. questId .. " is active!"
        if returnText and returnBrief then
            return "Eligible: Player is on quest"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    -- These are localized in the init function
    if QuestieCorrectionshiddenQuests[questId] then
        local msg = "Quest " .. questId .. " is hidden automatically!"
        if returnText and returnBrief then
            return "Unknown: Automatically blacklisted"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    if Questiedbcharhidden[questId] then
        local msg = "Quest " .. questId .. " is hidden manually!"
        if returnText and returnBrief then
            return "Unknown: Manually blacklisted"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    if Questiedbcharhidden[questId] then
        local msg = "Quest " .. questId .. " is hidden manually!"
        if returnText and returnBrief then
            return "Unknown: Manually blacklisted"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    -- We keep this here, even though it is removed from QuestieDB.IsDoable because AvailableQuests.CalculateAndDrawAll
    -- checks child quests differently and before IsDoable
    if QuestieDB.activeChildQuests[questId] then -- The parent quest is active, so this quest is doable
        local msg = "Quest " .. questId .. " is eligible because it's a child quest and the parent is active!"
        if returnText and returnBrief then
            return "Eligible: Parent active"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    local requiredRaces = QuestDB.requiredRaces(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredRaces")
    if (requiredRaces and not checkRace[requiredRaces]) then
        local msg = "Race requirement not fulfilled for quest " .. questId
        if returnText and returnBrief then
            return "Ineligible: Race requirement"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    local preQuestSingle = QuestDB.preQuestSingle(questId)-- QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle then
        local isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
        if not isPreQuestSingleFulfilled then
            local msg = "Pre-quest requirement not fulfilled for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Incomplete pre-quest"
            elseif returnText and not returnBrief then
                return msg
            end
        end
    end

    local requiredClasses = QuestDB.requiredClasses(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredClasses")
    if (requiredClasses and not checkClass[requiredClasses]) then
        QuestieDB.autoBlacklist[questId] = "class"
        local msg = "Class requirement not fulfilled for quest " .. questId
        if returnText and returnBrief then
            return "Ineligible: Class requirement"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    local requiredMinRep = QuestDB.requiredMinRep(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    local requiredMaxRep = QuestDB.requiredMaxRep(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")
    if (requiredMinRep or requiredMaxRep) then
        local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)
        if (not ((aboveMinRep and hasMinFaction) and (belowMaxRep and hasMaxFaction))) then
            --- If we haven't got the faction for min or max we blacklist it
            if not hasMinFaction or not hasMaxFaction then -- or not belowMaxRep -- This is something we could have done, but would break if you rep downwards
                QuestieDB.autoBlacklist[questId] = "rep"
            end

            local msg = "Player does not meet reputation requirements for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Reputation requirement"
            elseif returnText and not returnBrief then
                return msg
            end
        end
    end

    local requiredSkill = QuestDB.requiredSkill(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredSkill")
    if (requiredSkill) then
        local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
        if (not (hasProfession and hasSkillLevel)) then
            --? We haven't got the profession so we blacklist it.
            if(not hasProfession) then
                QuestieDB.autoBlacklist[questId] = "skill"
            end

            local msg = "Player does not meet profession requirements for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Profession requirement"
            elseif returnText and not returnBrief then
                return msg
            end
        end
    end

    --? PreQuestGroup and PreQuestSingle are mutualy exclusive to eachother and preQuestSingle is more prevalent
    --? Only try group if single does not exist.
    if not preQuestSingle then
        -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
        local preQuestGroup = QuestDB.preQuestGroup(questId)-- QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
        if preQuestGroup then
            local isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
            if not isPreQuestGroupFulfilled then
                local msg = "Group pre-quest requirement not fulfilled for quest " .. questId
                if returnText and returnBrief then
                    return "Ineligible: Incomplete pre-quest group"
                elseif returnText and not returnBrief then
                    return msg
                end
            end
        end
    end

    local parentQuest = QuestDB.parentQuest(questId)-- QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest and parentQuest ~= 0 then
        local msg = "Quest " .. questId .. " has an inactive parent quest"
        if returnText and returnBrief then
            return "Ineligible: Inactive parent"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    local nextQuestInChain = QuestDB.nextQuestInChain(questId)-- QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    if nextQuestInChain and nextQuestInChain ~= 0 then
        if completedQuests[nextQuestInChain] or currentQuestlog[nextQuestInChain] then
            local msg = "Follow up quests already completed or in the quest log for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Later quest completed or active " .. nextQuestInChain
            elseif returnText and not returnBrief then
                return msg
            end
        end
    end

    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    local ExclusiveQuestGroup = QuestDB.exclusiveTo(questId)-- QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
    if ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for _, v in pairs(ExclusiveQuestGroup) do
            if completedQuests[v] then
                local msg = "Player has completed exclusive quest " .. v
                if returnText and returnBrief then
                    return "Ineligible: Exclusive quest completed"
                elseif returnText and not returnBrief then
                    return msg
                end
            elseif currentQuestlog[v] then
                local msg = "Player has exclusive quest " .. v .. " in their quest log"
                if returnText and returnBrief then
                    return "Ineligible: Exclusive quest in quest log"
                elseif returnText and not returnBrief then
                    return msg
                end
            end
        end
    end

    if (not DailyQuests:IsActiveDailyQuest(questId)) then
        local msg = "Quest " .. questId .. " is a daily quest which isn't active today!"
        if returnText and returnBrief then
            return "Ineligible: Inactive daily"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    local requiredSpecialization = QuestDB.requiredSpecialization(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredSpecialization")
    if (requiredSpecialization) and (requiredSpecialization > 0) then
        local hasSpecialization = QuestieProfessions:HasSpecialization(requiredSpecialization)
        if (not hasSpecialization) then
            local msg = "Player does not meet profession specialization requirements for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Profession specialization requirement"
            elseif returnText and not returnBrief then
                return msg
            end
        end
    end

    local requiredSpell = QuestDB.requiredSpell(questId)-- QuestieDB.QueryQuestSingle(questId, "requiredSpell")
    if (requiredSpell) and (requiredSpell ~= 0) then
        local hasSpell = IsSpellKnownOrOverridesKnown(math.abs(requiredSpell))
        local hasProfSpell = IsPlayerSpell(math.abs(requiredSpell))
        if (requiredSpell > 0) and (not hasSpell) and (not hasProfSpell) then --if requiredSpell is positive, we make the quest ineligible if the player does NOT have the spell
            local msg = "Player does not meet learned spell requirements for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Spell not yet learned"
            elseif returnText and not returnBrief then
                return msg
            end
        elseif (requiredSpell < 0) and (hasSpell or hasProfSpell) then --if requiredSpell is negative, we make the quest ineligible if the player DOES  have the spell
            local msg = "Player does not meet unlearned spell requirements for quest " .. questId
            if returnText and returnBrief then
                return "Ineligible: Already learned spell"
            elseif returnText and not returnBrief then
                return msg
            end
        end
    end

    -- Check and see if the Quest requires an achievement before showing as available
    if _QuestieDB:CheckAchievementRequirements(questId) == false then
        local msg = "Player does not meet achievement requirements for quest " .. questId
        if returnText and returnBrief then
            return "Ineligible: Achievement requirement"
        elseif returnText and not returnBrief then
            return msg
        end
    end

    -- Check if this quest is a breadcrumb
    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(questId, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
        -- Check the target quest of this breadcrumb
        if completedQuests[breadcrumbForQuestId] or currentQuestlog[breadcrumbForQuestId] then
            if returnText and returnBrief then
                return "Ineligible: Breadcrumb target " .. breadcrumbForQuestId .. " active or finished"
            elseif returnText and not returnBrief then
                return "Target of breadcrumb quest " .. breadcrumbForQuestId .. " already completed or in the quest log for quest " .. questId
            end
        end
        -- Check if the other breadcrumbs are active
        local otherBreadcrumbs = QuestieDB.QueryQuestSingle(breadcrumbForQuestId, "breadcrumbs")
        for _, breadcrumbId in ipairs(otherBreadcrumbs) do
            if breadcrumbId ~= questId and currentQuestlog[breadcrumbId] then
                if returnText and returnBrief then
                    return "Ineligible: Another breadcrumb is active: " .. breadcrumbId
                elseif returnText and not returnBrief then
                    return "Alternative breadcrumb quest " .. breadcrumbId .." in the quest log for quest " .. questId
                end
            end
        end
    end

    -- Check if this quest has active breadcrumbs
    local breadcrumbs = QuestieDB.QueryQuestSingle(questId, "breadcrumbs")
    if breadcrumbs then
        for _, breadcrumbId in ipairs(breadcrumbs) do
            if currentQuestlog[breadcrumbId] then
                if returnText and returnBrief then
                    return "Ineligible: A breadcrumb is active: " .. breadcrumbId
                elseif returnText and not returnBrief then
                    return "A breadcrumb quest " .. breadcrumbId .." is in the quest log for quest " .. questId
                end
            end
        end
    end

    if DailyQuests.ShouldBeHidden(questId, completedQuests, currentQuestlog) then
        if returnText and returnBrief then
            return "Ineligible: Daily quest not active"
        elseif returnText then
            return "Daily quest " .. questId .. " is not active"
        end
    end

    if returnText then
        return "Player is eligible for quest " .. questId .. "!"
    else
        return ""
    end
end

---@param questId number
---@return number @Complete = 1, Failed = -1, Incomplete = 0
function QuestieDB.IsComplete(questId)
    local questLogEntry = QuestLogCache.questLog_DO_NOT_MODIFY[questId] -- DO NOT MODIFY THE RETURNED TABLE
    local noQuestItem = not QuestieQuest:CheckQuestSourceItem(questId, false)

    --[[ pseudo:
    if no questLogEntry then return 0
    if has questLogEntry.isComplete then return questLogEntry.isComplete
    if no objectives and an item is needed but not obtained then return 0
    if no objectives then return 1
    return 0
    --]]

    return questLogEntry and (questLogEntry.isComplete or (questLogEntry.objectives[1] and 0) or (#questLogEntry.objectives == 0 and noQuestItem and 0) or 1) or 0
end

---@param self Quest
---@return number @Complete = 1, Failed = -1, Incomplete = 0
local function _IsComplete(self)
    return QuestieDB.IsComplete(self.Id)
end

---@param questLevel number the level of the quest
---@return boolean @Returns true if the quest should be grey, false otherwise
function QuestieDB.IsTrivial(questLevel)
    if questLevel == -1 then
        return false -- Scaling quests are never trivial
    end

    local levelDiff = questLevel - QuestiePlayer.GetPlayerLevel();
    if (levelDiff >= 5) then
        return false -- Red
    elseif (levelDiff >= 3) then
        return false -- Orange
    elseif (levelDiff >= -2) then
        return false -- Yellow
    elseif (-levelDiff <= GetQuestGreenRange("player")) then
        return false -- Green
    else
        return true -- Grey
    end
end

---@return number
local _GetIconScale = function()
    return Questie.db.profile.objectScale or 1
end

---@param questId QuestId
---@return Quest|nil @The quest object or nil if the quest is missing
function QuestieDB.GetQuest(questId) -- /dump QuestieDB.GetQuest(867)
    if not questId then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB.GetQuest] No questId.")
        return nil
    end
    if _QuestieDB.questCache[questId] then
        return _QuestieDB.questCache[questId];
    end

    local rawdata = QuestieDB.QueryQuest(questId, QuestieDB._questAdapterQueryOrder)

    if (not rawdata) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB.GetQuest] rawdata is nil for questID:", questId)
        return nil
    end

    ---@class Quest
    ---@field public Id QuestId
    ---@field public name Name
    ---@field public startedBy StartedBy
    ---@field public finishedBy FinishedBy
    ---@field public requiredLevel Level
    ---@field public questLevel Level
    ---@field public requiredRaces number @bitmask
    ---@field public requiredClasses number @bitmask
    ---@field public objectivesText string[]
    ---@field public triggerEnd { [1]: string, [2]: table<AreaId, CoordPair[]>}
    ---@field public objectives RawObjectives
    ---@field public sourceItemId ItemId
    ---@field public preQuestGroup QuestId[]
    ---@field public preQuestSingle QuestId[]
    ---@field public childQuests QuestId[]
    ---@field public inGroupWith QuestId[]
    ---@field public exclusiveTo QuestId[]
    ---@field public zoneOrSort ZoneOrSort
    ---@field public requiredSkill SkillPair
    ---@field public requiredMinRep ReputationPair
    ---@field public requiredMaxRep ReputationPair
    ---@field public requiredSourceItems ItemId[]
    ---@field public nextQuestInChain number
    ---@field public questFlags number @bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ---@field public specialFlags number @bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ---@field public parentQuest QuestId
    ---@field public reputationReward ReputationPair[]
    ---@field public extraObjectives ExtraObjective[]
    ---@field public requiredMaxLevel Level
    ---@field public isComplete boolean
    ---@field public Color Color
    ---@field public breacrumbForQuestId number
    ---@field public breacrumbs QuestId[]
    local QO = {
        Id = questId
    }

    -- General filling of the QuestObjective with all database values
    local questKeys = QuestieDB.questKeys
    for stringKey, intKey in pairs(questKeys) do
        QO[stringKey] = rawdata[intKey]
    end

    local questLevel, requiredLevel = QuestieLib.GetTbcLevel(questId)
    QO.level = questLevel
    QO.requiredLevel = requiredLevel

    ---@type StartedBy
    local startedBy = QO.startedBy
    ---@type Starters
    QO.Starts = { -- TODO: Rename to Starters
        NPC = startedBy[1],
        GameObject = startedBy[2],
        Item = startedBy[3],
    }
    QO.isHidden = rawdata.hidden or QuestieCorrections.hiddenQuests[questId]
    QO.Description = QO.objectivesText
    if QO.specialFlags then
        QO.IsRepeatable = bitband(QO.specialFlags, 1) ~= 0
    end

    QO.IsComplete = _IsComplete

    ---@type FinishedBy
    local finishedBy = QO.finishedBy
    ---@type Finisher
    QO.Finisher = {
        NPC = finishedBy[1],
        GameObject = finishedBy[2],
    }

    --- to differentiate from the current quest log info.
    --- Quest objectives generated from DB+Corrections.
    --- Data itself is for example for monster type { Type = "monster", Id = 16518, Text = "Nestlewood Owlkin inoculated" }
    ---@type Objective[]
    QO.ObjectiveData = {}

    ---@type RawObjectives
    local objectives = QO.objectives
    if objectives then
        if objectives[1] then
            for _, creatureObjective in pairs(objectives[1]) do
                if creatureObjective then
                    if creatureObjective[3] == 0 then
                        creatureObjective[3] = nil
                    end
                    ---@type NpcObjective
                    QO.ObjectiveData[#QO.ObjectiveData+1] = {
                        Type = "monster",
                        Id = creatureObjective[1],
                        Text = creatureObjective[2],
                        Icon = creatureObjective[3]
                    }
                end
            end
        end
        if objectives[2] then
            for _, objectObjective in pairs(objectives[2]) do
                if objectObjective then
                    if objectObjective[3] == 0 then
                        objectObjective[3] = nil
                    end
                    ---@type ObjectObjective
                    QO.ObjectiveData[#QO.ObjectiveData+1] = {
                        Type = "object",
                        Id = objectObjective[1],
                        Text = objectObjective[2],
                        Icon = objectObjective[3]
                    }
                    if QuestieCorrections.objectObjectiveFirst[questId] then
                        tinsert(QO.ObjectiveData, 1, QO.ObjectiveData[#QO.ObjectiveData])
                        tremove(QO.ObjectiveData)
                    end
                end
            end
        end
        if objectives[3] then
            for _, itemObjective in pairs(objectives[3]) do
                if itemObjective then
                    if itemObjective[3] == 0 then
                        itemObjective[3] = nil
                    end
                    ---@type ItemObjective
                    QO.ObjectiveData[#QO.ObjectiveData+1] = {
                        Type = "item",
                        Id = itemObjective[1],
                        Text = itemObjective[2],
                        Icon = itemObjective[3]
                    }
                    if QuestieCorrections.itemObjectiveFirst[questId] then
                        tinsert(QO.ObjectiveData, 1, QO.ObjectiveData[#QO.ObjectiveData])
                        tremove(QO.ObjectiveData)
                    end
                end
            end
        end
        if objectives[4] then
            ---@type ReputationObjective
            QO.ObjectiveData[#QO.ObjectiveData+1] = {
                Type = "reputation",
                Id = objectives[4][1],
                RequiredRepValue = objectives[4][2]
            }
        end
        if objectives[5] and type(objectives[5]) == "table" and #objectives[5] > 0 then
            for _, creditObjective in pairs(objectives[5]) do
                if creditObjective[4] == 0 then
                    creditObjective[4] = nil
                end
                ---@type KillObjective
                local killCreditObjective = {
                    Type = "killcredit",
                    IdList = creditObjective[1],
                    RootId = creditObjective[2],
                    Text = creditObjective[3],
                    Icon = creditObjective[4]
                }

                --? There are quest(s) which have the killCredit first so we need to switch them
                -- Place the kill credit objective first
                if QuestieCorrections.killCreditObjectiveFirst[questId] then
                    tinsert(QO.ObjectiveData, 1, killCreditObjective);
                else
                    tinsert(QO.ObjectiveData, killCreditObjective);
                end
            end
        end
        if objectives[6] then
            for index, spellObjective in pairs(objectives[6]) do
                if spellObjective then
                    ---@type SpellObjective
                    QO.ObjectiveData[#QO.ObjectiveData+1] = {
                        Type = "spell",
                        Id = spellObjective[1],
                        Text = spellObjective[2],
                        ItemSourceId = spellObjective[3],
                    }
                    QO.SpellItemId = spellObjective[3]
                end

                --? There are quest(s) which have the spellObjective first so we need to switch them
                -- Place the spell objective first
                if QuestieCorrections.spellObjectiveFirst[questId] then
                    tinsert(QO.ObjectiveData, 1, spellObjective);
                else
                    tinsert(QO.ObjectiveData, spellObjective);
                end
            end
        end
    end

    -- Events need to be added at the end of ObjectiveData
    local triggerEnd = QO.triggerEnd
    if triggerEnd then
        ---@type TriggerEndObjective
        QO.ObjectiveData[#QO.ObjectiveData+1] = {
            Type = "event",
            Text = triggerEnd[1],
            Coordinates = triggerEnd[2]
        }
        if QuestieCorrections.eventObjectiveFirst[questId] then
            tinsert(QO.ObjectiveData, 1, QO.ObjectiveData[#QO.ObjectiveData])
            tremove(QO.ObjectiveData)
        end
    end

    --- Quest objectives generated from quest log in QuestieQuest.lua -> QuestieQuest:PopulateQuestLogInfo(quest)
    --- Includes also icons drawn to maps, and other stuff.
    ---@type table<ObjectiveIndex, QuestObjective>
    QO.Objectives = {}

    QO.SpecialObjectives = {}

    ---@type ItemId[]
    local requiredSourceItems = QO.requiredSourceItems
    if requiredSourceItems then
        for _, itemId in pairs(requiredSourceItems) do
            if itemId then
                -- TODO: This is not required anymore since we validate the database for this case
                -- Make sure requiredSourceItems aren't already an objective
                local itemObjPresent = false
                if objectives[3] then
                    for _, itemObjective in pairs(objectives[3]) do
                        if itemObjective then
                            if itemId == itemObjective[1] then
                                itemObjPresent = true
                                break
                            end
                        end
                    end
                end

                -- Make an objective for requiredSourceItem
                if not itemObjPresent then
                    QO.SpecialObjectives[itemId] = {
                        Type = "item",
                        Id = itemId,
                        ---@type string @We have to hard-type it here because of the function
                        Description = QuestieDB.QueryItemSingle(itemId, "name")
                    }
                end
            end
        end
    end

    ---@type ExtraObjective[]
    local extraObjectives = QO.extraObjectives
    if extraObjectives then
        for index, o in pairs(extraObjectives) do
            local specialObjective = {
                Icon = o[2],
                Description = o[3],
                RealObjectiveIndex = o[4],
            }
            if o[1] then -- custom spawn
                specialObjective.spawnList = {{
                    Name = o[3],
                    Spawns = o[1],
                    Icon = o[2],
                    GetIconScale = _GetIconScale,
                    IconScale = _GetIconScale(),
                }}
            end
            if o[5] then -- db ref
                specialObjective.Type = o[5][1][1]
                specialObjective.Id = o[5][1][2]
                local spawnList = {}

                for _, ref in pairs(o[5]) do
                    for k, v in pairs(_QuestieQuest.objectiveSpawnListCallTable[ref[1]](ref[2], specialObjective)) do
                        -- we want to be able to override the icon in the corrections (e.g. Questie.ICON_TYPE_OBJECT on objects instead of Questie.ICON_TYPE_LOOT)
                        v.Icon = o[2]
                        spawnList[k] = v
                    end
                end

                specialObjective.spawnList = spawnList
            end
            QO.SpecialObjectives[index] = specialObjective
        end
    end

    _QuestieDB.questCache[questId] = QO
    return QO
end

QuestieDB._CreatureLevelCache = {}
---@param quest Quest
---@return table<string, table> @List of creature names with their min-max level and rank
function QuestieDB:GetCreatureLevels(quest)
    if quest and QuestieDB._CreatureLevelCache[quest.Id] then
        return QuestieDB._CreatureLevelCache[quest.Id]
    end
    local creatureLevels = {}

    local function _CollectCreatureLevels(npcIds)
        for _, npcId in pairs(npcIds) do
            local npc = QuestieDB:GetNPC(npcId)
            if npc and not creatureLevels[npc.name] then
                creatureLevels[npc.name] = {npc.minLevel, npc.maxLevel, npc.rank}
            end
        end
    end

    if quest.objectives then
        if quest.objectives[1] then -- Killing creatures
            for _, creatureObjective in pairs(quest.objectives[1]) do
                local npcId = creatureObjective[1]
                _CollectCreatureLevels({npcId})
            end
        end
        if quest.objectives[3] then -- Looting items from creatures
            for _, itemObjective in pairs(quest.objectives[3]) do
                local itemId = itemObjective[1]
                local npcIds = QuestieDB.QueryItemSingle(itemId, "npcDrops")
                if npcIds then
                    _CollectCreatureLevels(npcIds)
                end
            end
        end
    end
    if quest.Id then
        QuestieDB._CreatureLevelCache[quest.Id] = creatureLevels
    end
    return creatureLevels
end

---@param npcId NpcId
---@return NPC|nil
function QuestieDB:GetNPC(npcId)
    if not npcId then
        return nil
    end
    if _QuestieDB.npcCache[npcId] then
        return _QuestieDB.npcCache[npcId]
    end

    local rawdata = QuestieDB.QueryNPC(npcId, QuestieDB._npcAdapterQueryOrder)
    if (not rawdata) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetNPC] rawdata is nil for npcID:", npcId)
        return nil
    end

    local npcKeys = QuestieDB.npcKeys
    local npc = {
        id = npcId,
        type = "monster",
    }
    for stringKey, intKey in pairs(npcKeys) do
        npc[stringKey] = rawdata[intKey]
    end

    local friendlyToFaction = rawdata[npcKeys.friendlyToFaction]
    npc.friendly = QuestieDB.IsFriendlyToPlayer(friendlyToFaction)

    _QuestieDB.npcCache[npcId] = npc
    return npc
end

---@param friendlyToFaction string --The NPC database field friendlyToFaction - so either nil, "A", "H" or "AH"
---@return boolean
function QuestieDB.IsFriendlyToPlayer(friendlyToFaction)
    if (not friendlyToFaction) or friendlyToFaction == "AH" then
        return true
    end

    if friendlyToFaction == "H" then
        return QuestiePlayer.faction == "Horde"
    elseif friendlyToFaction == "A" then
        return QuestiePlayer.faction == "Alliance"
    end

    return false
end

---------------------------------------------------------------------------------------------------
-- Modifications to objectDB
function _QuestieDB:DeleteGatheringNodes()
    local prune = { -- gathering nodes
        1617,1618,1619,1620,1621,1622,1623,1624,1628, -- herbs

        1731,1732,1733,1734,1735,123848,150082,175404,176643,177388,324,150079,176645,2040,123310 -- mining
    }
    local objectSpawnsKey = QuestieDB.objectKeys.spawns
    for i=1, #prune do
        local id = prune[i]
        QuestieDB.objectData[id][objectSpawnsKey] = nil
    end
end

---------------------------------------------------------------------------------------------------
-- Modifications to questDB

local questsRequiringNewbieAchievement = {
    [31316] = true, -- Julia, The Pet Tamer -- Alliance
    [31812] = true, -- Zunta, The Pet Tamer -- Horde
    [32008] = true, -- Audrey Burnhep -- Alliance
    [32009] = true, -- Varzok -- Horde
}

local questsRequiringTamingKalimdorAchievement = {
    [31818] = true, -- Zunta
    [31819] = true, -- Dagra the Fierce
    [31854] = true, -- Analynn
    [31862] = true, -- Zonya the Sadist
    [31871] = true, -- Traitor Gluk
    [31872] = true, -- Merda Stronghoof
    [31904] = true, -- Cassandra Kaboom
    [31905] = true, -- Grazzle the Great
    [31906] = true, -- Kela Grimtotem
    [31907] = true, -- Zoltan
    [31908] = true, -- Elena Flutterfly
}

local questsRequiringTamingEasternKingdomsAchievement = {
    [31693] = true, -- Julia Stevens
    [31780] = true, -- Old MacDonald
    [31781] = true, -- Lindsay
    [31850] = true, -- Eric Davidson
    [31851] = true, -- Bill Buckler
    [31852] = true, -- Steven Lisbane
    [31910] = true, -- David Kosse
    [31911] = true, -- Deiza Plaguehorn
    [31912] = true, -- Kortas Darkhammer
    [31913] = true, -- Everessa
    [31914] = true, -- Durin Darkhammer
}

local questsRequiringTamingOutlandAchievement = {
    [31922] = true, -- Nicki Tinytech
    [31923] = true, -- Ras'an
    [31924] = true, -- Narrok
    [31925] = true, -- Morulu The Elder
    [31926] = true, -- Grand Master Antari
}

local questsRequiringTamingNorthrendAchievement = {
    [31931] = true, -- Beegle Blastfuse
    [31932] = true, -- Nearly Headless Jacob
    [31933] = true, -- Okrut Dragonwaste
    [31934] = true, -- Gutretch
    [31935] = true, -- Grand Master Payne
}

local questsRequiringTamingCataclysmAchievement = {
    [31971] = true, -- Grand Master Obalis
    [31972] = true, -- Brok
    [31973] = true, -- Bordin Steadyfist
    [31974] = true, -- Goz Banefury
}

local questsRequiringTamingPandariaAchievement = {
    [31953] = true, -- Grand Master Hyuna
    [31954] = true, -- Grand Master Mo'ruk
    [31955] = true, -- Grand Master Nishi
    [31956] = true, -- Grand Master Yon
    [31957] = true, -- Grand Master Shu
    [31958] = true, -- Grand Master Aki
    [31991] = true, -- Grand Master Zusshi
    [33222] = true, -- Little Tommy Newcomer
}

local questsRequiringPandarenSpiritTamerAchievement = {
    [32434] = true, -- Burning Pandaren Spirit
    [32439] = true, -- Flowing Pandaren Spirit
    [32440] = true, -- Whispering Pandaren Spirit
    [32441] = true, -- Thundering Pandaren Spirit
}

local questsRequiringFabledPandarenTamerAchievement = {
    [32604] = true, -- Beasts of Fable Book I
    [32868] = true, -- Beasts of Fable Book II
    [32869] = true, -- Beasts of Fable Book III
}

local questsRequiringFriendsOnTheFarmAchievement = {
    [31312] = true, -- The Old Map
}

function _QuestieDB:CheckAchievementRequirements(questId)
    -- So far the only Quests that we know of that requires an earned Achievement are the ones offered by:
    -- https://www.wowhead.com/wotlk/npc=35094/crusader-silverdawn
    -- Get Kraken (14108)
    -- The Fate Of The Fallen (14107)
    -- This NPC requires these earned Achievements baseed on a Players home faction:
    -- https://www.wowhead.com/wotlk/achievement=2817/exalted-argent-champion-of-the-alliance
    -- https://www.wowhead.com/wotlk/achievement=2816/exalted-argent-champion-of-the-horde
    if questId == 14101 or questId == 14102 or questId == 14104 or questId == 14105 or questId == 14107 or questId == 14108 then
        if select(13, GetAchievementInfo(2817)) or select(13, GetAchievementInfo(2816)) then
            return true
        end

        return false
    end

    if questsRequiringNewbieAchievement[questId] then
        return select(13, GetAchievementInfo(7433)) -- Newbie
    end

    if questsRequiringTamingKalimdorAchievement[questId] then
        return select(13, GetAchievementInfo(6602)) -- Taming Kalimdor
    end

    if questsRequiringTamingEasternKingdomsAchievement[questId] then
        return select(13, GetAchievementInfo(6603)) -- Taming Eastern Kingdoms
    end

    if questsRequiringTamingOutlandAchievement[questId] then
        return select(13, GetAchievementInfo(6604)) -- Taming Outland
    end

    if questsRequiringTamingNorthrendAchievement[questId] then
        return select(13, GetAchievementInfo(6605)) -- Taming Northrend
    end

    if questsRequiringTamingCataclysmAchievement[questId] then
        return select(13, GetAchievementInfo(7525)) -- Taming Cataclysm
    end

    if questsRequiringTamingPandariaAchievement[questId] then
        return select(13, GetAchievementInfo(6606)) -- Taming Pandaria
    end

    if questsRequiringPandarenSpiritTamerAchievement[questId] then
        return select(13, GetAchievementInfo(7936)) -- Pandaren Spirit Tamer
    end

    if questsRequiringFabledPandarenTamerAchievement[questId] then
        return select(13, GetAchievementInfo(8080)) -- Beasts of Fable
    end

    if questsRequiringFriendsOnTheFarmAchievement[questId] then
        return select(13, GetAchievementInfo(6552)) -- Friends On The Farm
    end
end

function _QuestieDB:HideClassAndRaceQuests()
    local questKeys = QuestieDB.questKeys
    for _, entry in pairs(QuestieDB.questData) do
        -- check requirements, set hidden flag if not met
        local requiredClasses = entry[questKeys.requiredClasses]
        if (requiredClasses) and (requiredClasses ~= 0) then
            if (not QuestiePlayer.HasRequiredClass(requiredClasses)) then
                entry.hidden = true
            end
        end
        local requiredRaces = entry[questKeys.requiredRaces]
        if (requiredRaces) and (requiredRaces ~= 0) and (requiredRaces ~= 255) then
            if (not QuestiePlayer.HasRequiredRace(requiredRaces)) then
                entry.hidden = true
            end
        end
    end
    Questie:Debug(Questie.DEBUG_DEVELOP, "Other class and race quests hidden");
end

-- This function is intended for usage with Gossip and Greeting frames, where there's a list of quests but no QuestIDs are
-- obtainable until entering the specific quest dialog.
-- This is a bruteforce method for obtaining a QuestID with no input other than a quest name, and the ID of the questgiver.
-- It compares the name of the quest entry with the names of every quest that questgiver can either start or end.
---@param name string? @The name of the quest entry
---@param questgiverGUID string? @Should be UnitGUID("questnpc")
---@param questStarter boolean @Should be True if this is an available quest, False if this is an "active" quest (quest ender)
---@return number
function QuestieDB.GetQuestIDFromName(name, questgiverGUID, questStarter)
    local questID = 0 -- worst case, we end up returning an ID of 0 if we can't find a match; any function relying on this one should handle 0 cleanly
    if questgiverGUID then
        local questgiverID = tonumber(questgiverGUID:match("-(%d+)-%x+$"), 10)
        local unit_type = strsplit("-", questgiverGUID)
        local questsStarted
        local questsEnded
        if unit_type == "Creature" then -- if questgiver is an NPC
            questsStarted = QuestieDB.QueryNPCSingle(questgiverID, "questStarts")
            questsEnded = QuestieDB.QueryNPCSingle(questgiverID, "questEnds")
        elseif unit_type == "GameObject" then -- if questgiver is an object (it's rare for an object to have a gossip/greeting frame, but Wanted Boards exist; see object 2713)
            questsStarted = QuestieDB.QueryObjectSingle(questgiverID, "questStarts")
            questsEnded = QuestieDB.QueryObjectSingle(questgiverID, "questEnds")
        else
            return questID; -- If the questgiver is not an NPC or object, bail!
        end
        -- iterate through every questEnds entry in our questgiver's DB, and check if each quest name matches this greeting frame entry
        if questStarter == true then
            if questsStarted then
                for _, id in pairs(questsStarted) do
                    if (name == QuestieDB.QueryQuestSingle(id, "name")) and (QuestieDB.IsDoable(id)) then
                        -- the QuestieDB.IsDoable check is important to filter out identically named quests
                        questID = id
                    end
                end
            elseif Questie.IsSoD == false then -- don't print these errors in SoD, as we expect missing data when new quests release; debug offers will handle these scenarios instead
                Questie:Error("Database mismatch! No entries found that match quest name. Please report this on Github or Discord!")
                Questie:Error("Queststarter is: " .. unit_type .. " " .. questgiverID)
                Questie:Error("Quest name is: " .. name)
                Questie:Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
            end
        else
            if questsEnded then
                for _, id in pairs(questsEnded) do
                    if (name == QuestieDB.QueryQuestSingle(id, "name")) and (QuestieDB.IsDoable(id)) and QuestiePlayer.currentQuestlog[id] then
                        questID = id
                    end
                end
            elseif Questie.IsSoD == false then -- don't print these errors in SoD, as we expect missing data when new quests release; debug offers will handle these scenarios instead
                Questie:Error("Database mismatch! No entries found that match quest name. Please report this on Github or Discord!")
                Questie:Error("Questender is: " .. unit_type .. " " .. questgiverID)
                Questie:Error("Quest name is: " .. name)
                Questie:Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
            end
        end
    end
    return questID;
end

--TODO: Remove this
QuestieDB.waypointPresets = {
    ORGRIMS_HAMMER = {[ZoneDB.zoneIDs.ICECROWN]={{{62.37,30.60},{61.93,30.93},{61.48,31.24},{61.08,31.55},{60.74,31.92},{60.46,32.44},{60.26,33.11},{60.14,33.85},{60.11,34.63},{60.17,35.35},{60.31,36.01},{60.56,36.66},{60.84,37.33},{61.15,38.00},{61.44,38.67},{61.71,39.28},{62.00,39.92},{62.31,40.55},{62.60,41.20},{62.90,41.83},{63.05,42.20},{63.33,42.85},{63.58,43.53},{63.85,44.19},{64.08,44.86},{64.33,45.50},{64.45,45.87},{64.69,46.56},{64.94,47.21},{65.16,47.87},{65.43,48.51},{65.71,49.15},{66.03,49.77},{66.36,50.46},{66.72,51.10},{67.07,51.67},{67.41,52.08},{67.82,52.37},{68.31,52.47},{68.80,52.38},{69.23,51.98},{69.45,51.56},{69.57,51.13},{69.67,50.59},{69.73,49.96},{69.77,49.26},{69.79,48.48},{69.80,47.62},{69.79,46.68},{69.79,45.68},{69.78,44.90},{69.78,44.25},{69.76,43.55},{69.75,42.80},{69.72,42.01},{69.70,41.20},{69.67,40.38},{69.64,39.54},{69.61,38.71},{69.58,37.88},{69.55,37.07},{69.52,36.28},{69.49,35.54},{69.46,34.83},{69.45,34.18},{69.42,33.50},{69.41,32.46},{69.42,31.52},{69.45,30.67},{69.47,29.92},{69.48,29.25},{69.46,28.65},{69.42,28.12},{69.35,27.83},{69.11,27.19},{68.71,26.77},{68.23,26.54},{67.71,26.51},{67.24,26.55},{66.81,26.76},{66.35,27.09},{65.90,27.52},{65.44,27.95},{65.01,28.39},{64.58,28.73},{64.16,29.10},{63.74,29.43},{63.34,29.79},{62.94,30.11},{62.65,30.37},{62.37,30.60}}}},
    THE_SKYBREAKER = {[ZoneDB.zoneIDs.ICECROWN]={{{63.59,52.34},{63.44,51.88},{63.30,51.52},{63.15,51.19},{63.01,50.85},{62.85,50.52},{62.68,50.17},{62.50,49.78},{62.31,49.36},{62.09,48.88},{61.86,48.33},{61.81,48.20},{61.67,47.88},{61.52,47.52},{61.37,47.13},{61.19,46.74},{61.02,46.32},{60.84,45.88},{60.65,45.44},{60.46,44.99},{60.28,44.53},{60.09,44.08},{59.90,43.63},{59.72,43.18},{59.54,42.75},{59.36,42.34},{59.20,41.94},{59.04,41.56},{58.89,41.22},{58.75,40.87},{58.52,40.30},{58.32,39.77},{58.14,39.27},{57.97,38.80},{57.81,38.39},{57.65,38.03},{57.49,37.72},{57.31,37.50},{57.12,37.34},{56.87,37.29},{56.57,37.39},{56.27,37.60},{55.97,37.88},{55.72,38.23},{55.53,38.61},{55.43,38.95},{55.43,39.09},{55.46,39.49},{55.52,39.92},{55.62,40.39},{55.76,40.88},{55.89,41.38},{56.02,41.85},{56.17,42.25},{56.33,42.68},{56.51,43.13},{56.70,43.56},{56.88,43.99},{57.05,44.39},{57.22,44.74},{57.42,45.15},{57.64,45.52},{57.83,45.81},{58.03,46.14},{58.23,46.56},{58.41,46.90},{58.60,47.25},{58.80,47.62},{59.00,48.03},{59.19,48.46},{59.36,48.84},{59.53,49.22},{59.69,49.63},{59.86,50.04},{60.03,50.46},{60.19,50.90},{60.36,51.32},{60.51,51.74},{60.65,52.17},{60.79,52.59},{60.94,53.02},{61.07,53.46},{61.23,53.89},{61.39,54.30},{61.55,54.72},{61.70,55.18},{61.88,55.65},{62.05,56.14},{62.23,56.58},{62.43,56.95},{62.65,57.21},{62.87,57.30},{62.95,57.27},{63.22,57.16},{63.52,56.97},{63.81,56.68},{64.07,56.32},{64.26,55.91},{64.33,55.47},{64.30,55.11},{64.25,54.72},{64.16,54.30},{64.04,53.84},{63.91,53.36},{63.76,52.88},{63.59,52.34}}}},
    ALLIANCE_GUNSHIP = {[ZoneDB.zoneIDs.DEEPHOLM]={{{61.79,46.28},{61.68,45.72},{61.55,45.10},{61.45,44.56},{61.34,43.97},{61.22,43.46},{61.13,42.90},{61.06,42.23},{60.98,41.63},{60.90,40.98},{60.84,40.28},{60.81,39.59},{60.84,38.98},{60.99,38.55},{61.33,38.23},{61.75,38.04},{62.21,38.04},{62.62,38.33},{62.82,38.82},{62.95,39.32},{63.07,39.93},{63.19,40.61},{63.30,41.31},{63.40,41.98},{63.49,42.57},{63.60,43.23},{63.69,43.90},{63.77,44.48},{63.85,44.98},{63.95,45.61},{64.05,46.15},{64.22,46.69},{64.31,47.26},{64.40,47.87},{64.47,48.40},{64.54,49.02},{64.62,49.71},{64.69,50.29},{64.76,50.96},{64.82,51.65},{64.84,52.29},{64.77,52.81},{64.59,53.41},{64.29,53.74},{63.93,53.82},{63.58,53.79},{63.15,53.70},{62.72,53.51},{62.42,53.16},{62.32,52.68},{62.27,52.08},{62.23,51.41},{62.20,50.75},{62.18,50.12},{62.22,49.50},{62.23,48.90},{62.19,48.31},{62.09,47.73},{61.97,47.12},{61.83,46.50},{61.79,46.28}}}},
}

return QuestieDB
