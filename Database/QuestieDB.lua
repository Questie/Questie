---@class QuestieDB
local QuestieDB = QuestieLoader:CreateModule("QuestieDB")

---@type QuestieDBPrivate
QuestieDB.private = QuestieDB.private or {}

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

local tinsert = table.insert

-- questFlags https://github.com/cmangos/issues/wiki/Quest_template#questflags
local QUEST_FLAGS_DAILY = 4096
-- Pre calculated 2 * QUEST_FLAGS_DAILY, for testing a bit flag
local QUEST_FLAGS_DAILY_X2 = 2 * QUEST_FLAGS_DAILY

--- Tag corrections for quests for which the API returns the wrong values.
--- Strucute: [questId] = {tagId, "questType"}
---@type table<number, {[1]: number, [2]: string}>
local questTagCorrections = {
    [373] = {81, "Dungeon"},
    [4146] = {81, "Dungeon"},
    [5342] = {0, ""},
    [5344] = {0, ""},
    [6846] = {41, "PvP"},
    [6901] = {41, "PvP"},
    [7001] = {41, "PvP"},
    [7027] = {41, "PvP"},
    [7161] = {41, "PvP"},
    [7162] = {41, "PvP"},
    [7841] = {0, ""},
    [7842] = {0, ""},
    [7843] = {0, ""},
    [8122] = {41, "PvP"},
    [8386] = {41, "PvP"},
    [8404] = {41, "PvP"},
    [8405] = {41, "PvP"},
    [8406] = {41, "PvP"},
    [8407] = {41, "PvP"},
    [8408] = {41, "PvP"},
}

-- race bitmask data, for easy access
local VANILLA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

QuestieDB.raceKeys = {
    ALL_ALLIANCE = VANILLA and 77 or 1101,
    ALL_HORDE = VANILLA and 178 or 690,
    NONE = 0,

    HUMAN = 1,
    ORC = 2,
    DWARF = 4,
    NIGHT_ELF = 8,
    UNDEAD = 16,
    TAUREN = 32,
    GNOME = 64,
    TROLL = 128,
    --GOBLIN = 256,
    BLOOD_ELF = 512,
    DRAENEI = 1024
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
    SHAMAN = 32,
    MAGE = 128,
    WARLOCK = 256,
    DRUID = 1024
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

local function _shutdown_db() -- prevent catastrophic error
    QuestieDB.QueryNPC = nil
    QuestieDB.QueryQuest = nil
    QuestieDB.QueryObject = nil
    QuestieDB.QueryItem = nil

    QuestieDB.QueryQuestSingle = nil
    QuestieDB.QueryNPCSingle = nil
    QuestieDB.QueryObjectSingle = nil
    QuestieDB.QueryItemSingle = nil
end

local function trycatch(func)
    return function(...)
        local result, ret = pcall(func, ...)
        if (not result) then
            print(ret)
            _shutdown_db()
            if not Questie.db.global.disableDatabaseWarnings then
                StaticPopup_Show ("QUESTIE_DATABASE_ERROR")
            else
                print(l10n("There was a problem initializing Questie's database. This can usually be fixed by recompiling the database."))
            end
        end
        return ret
    end
end

function QuestieDB:Initialize()

    StaticPopupDialogs["QUESTIE_DATABASE_ERROR"] = { -- /run StaticPopup_Show ("QUESTIE_DATABASE_ERROR")
        text = l10n("There was a problem initializing Questie's database. This can usually be fixed by recompiling the database."),
        button1 = l10n("Recompile Database"),
        button2 = l10n("Don't show again"),
        OnAccept = function()
            Questie.db.global.dbIsCompiled = false
            ReloadUI()
        end,
        OnDecline = function()
            Questie.db.global.disableDatabaseWarnings = true
        end,
        OnShow = function(self)
            self:SetFrameStrata("TOOLTIP")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3
    }

    QuestieDB.QueryNPC = QuestieDBCompiler:GetDBHandle(Questie.db.global.npcBin, Questie.db.global.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder), QuestieDB.npcKeys, QuestieDB.npcDataOverrides)
    QuestieDB.QueryQuest = QuestieDBCompiler:GetDBHandle(Questie.db.global.questBin, Questie.db.global.questPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder), QuestieDB.questKeys, QuestieDB.questDataOverrides)
    QuestieDB.QueryObject = QuestieDBCompiler:GetDBHandle(Questie.db.global.objBin, Questie.db.global.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder), QuestieDB.objectKeys, QuestieDB.objectDataOverrides)
    QuestieDB.QueryItem = QuestieDBCompiler:GetDBHandle(Questie.db.global.itemBin, Questie.db.global.itemPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder), QuestieDB.itemKeys, QuestieDB.itemDataOverrides)

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

    -- wrap in pcall and hope it doesnt cause too much overhead
    -- lua needs try-catch
    QuestieDB.QueryNPC = QuestieDB._QueryNPC
    QuestieDB.QueryQuest = QuestieDB._QueryQuest
    QuestieDB.QueryObject = QuestieDB._QueryObject
    QuestieDB.QueryItem = QuestieDB._QueryItem

    QuestieDB.QueryQuestSingle = QuestieDB._QueryQuestSingle
    QuestieDB.QueryNPCSingle = QuestieDB._QueryNPCSingle
    QuestieDB.QueryObjectSingle = QuestieDB._QueryObjectSingle
    QuestieDB.QueryItemSingle = QuestieDB._QueryItemSingle

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

function QuestieDB:GetObject(objectId)
    if not objectId then
        return nil
    end
    if _QuestieDB.objectCache[objectId] ~= nil then
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

function QuestieDB:GetItem(itemId)
    if (not itemId) or (itemId == 0) then
        return nil
    end
    if _QuestieDB.itemCache[itemId] ~= nil then
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
    return flags and mod(flags, 2) == 1
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
function QuestieDB.IsDungeonQuest(questId)
    local questType, _ = QuestieDB.GetQuestTagInfo(questId)
    return questType == 81
end

---@param questId number
---@return boolean
function QuestieDB.IsRaidQuest(questId)
    local questType, _ = QuestieDB.GetQuestTagInfo(questId)
    return questType == 62
end

---@param questId number
---@return boolean
function QuestieDB.IsPvPQuest(questId)
    local questType, _ = QuestieDB.GetQuestTagInfo(questId)
    return questType == 41
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

--- Wrapper function for the GetQuestTagInfo API to correct
--- quests that are falsely marked by Blizzard
---@param questId number
---@return number|nil questType, string|nil questTag
function QuestieDB.GetQuestTagInfo(questId)
    if questTagCorrections[questId] then
        return questTagCorrections[questId][1], questTagCorrections[questId][2]
    end
    local questType, questTag = GetQuestTagInfo(questId)

    return questType, questTag
end

---@param questId number
---@return boolean
function QuestieDB.IsActiveEventQuest(questId)
    --! If you edit the logic here, also edit in QuestieDB:IsLevelRequirementsFulfilled
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

---@param questId QuestId
---@param minLevel Level
---@param maxLevel Level
---@param playerLevel Level? @Pass player level to avoid calling UnitLevel or to use custom level
---@return boolean
function QuestieDB.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel)
    local level, requiredLevel = QuestieLib.GetTbcLevel(questId, playerLevel)

    --* QuestiePlayer.currentQuestlog[parentQuestId] logic is from QuestieDB.IsParentQuestActive, if you edit here, also edit there
    local parentQuestId = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuestId and QuestiePlayer.currentQuestlog[parentQuestId] then
        return true
    end

    --* QuestieEvent.activeQuests[questId] logic is from QuestieDB.IsParentQuestActive, if you edit here, also edit there
    if (not Questie.db.char.absoluteLevelOffset) and
        minLevel > requiredLevel and
        QuestieEvent.activeQuests[questId]  then
        return true
    end

    if maxLevel >= level then
        if (not Questie.db.char.lowlevel) and minLevel > level then
            return false
        end
    else
        if Questie.db.char.absoluteLevelOffset or maxLevel < requiredLevel then
            return false
        end
    end

    if maxLevel < requiredLevel then
        return false
    end

    return true
end

---@param parentID number
---@return boolean
function QuestieDB.IsParentQuestActive(parentID)
    --! If you edit the logic here, also edit in QuestieDB:IsLevelRequirementsFulfilled
    if (not parentID) or (parentID == 0) then
        return false
    end
    if QuestiePlayer.currentQuestlog[parentID] then
        return true
    end
    return false
end

---@param preQuestGroup table<number, number>
---@return boolean
function QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
    if not preQuestGroup then
        return true
    end
    for preQuestIndex=1, #preQuestGroup do
        -- If a quest is not complete and no exlusive quest is complete, the requirement is not fulfilled
        if not Questie.db.char.complete[preQuestGroup[preQuestIndex]] then
            local preQuest = QuestieDB.QueryQuestSingle(preQuestGroup[preQuestIndex], "exclusiveTo")
            if (not preQuest) then
                return false
            end

            local anyExlusiveFinished = false
            for i=1, #preQuest do
                if Questie.db.char.complete[preQuest[i]] then
                    anyExlusiveFinished = true
                end
            end
            if not anyExlusiveFinished then
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
    if not preQuestSingle then
        return true
    end
    for preQuestIndex=1, #preQuestSingle do
    -- for _, preQuestId in pairs(preQuestSingle) do
        -- If a quest is complete the requirement is fulfilled
        if Questie.db.char.complete[preQuestSingle[preQuestIndex]] then
            return true
        -- If one of the quests in the exclusive group is complete the requirement is fulfilled
        else
            local preQuestExclusiveQuestGroup = QuestieDB.QueryQuestSingle(preQuestSingle[preQuestIndex], "exclusiveTo")
            if preQuestExclusiveQuestGroup then
                for i=1, #preQuestExclusiveQuestGroup do
                    if Questie.db.char.complete[preQuestExclusiveQuestGroup[i]] then
                        return true
                    end
                end
            end
        end
    end
    -- No preQuest is complete
    return false
end

---@param questId number
---@param debugPrint boolean?
---@return boolean
function QuestieDB.IsDoable(questId, debugPrint)

    -- These are localized in the init function
    if QuestieCorrectionshiddenQuests[questId] then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] quest is hidden!") end
        return false
    end

    if Questiedbcharhidden[questId] then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] quest is hidden manually!") end
        return false
    end

    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")
    if (requiredRaces and not checkRace[requiredRaces]) then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] race requirement not fulfilled for questId:", questId) end
        QuestieQuest.autoBlacklist[questId] = "race"
        return false
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle ~= nil then
        local isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
        if not isPreQuestSingleFulfilled then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] preQuestSingle requirement not fulfilled for questId:", questId) end
            return false
        end
    end

    local requiredClasses = QuestieDB.QueryQuestSingle(questId, "requiredClasses")
    if (requiredClasses and not checkClass[requiredClasses]) then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] class requirement not fulfilled for questId:", questId) end
        QuestieQuest.autoBlacklist[questId] = "class"
        return false
    end

    local requiredMinRep = QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    local requiredMaxRep = QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")
    if (requiredMinRep or requiredMaxRep) then
        local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)
        if (not ((aboveMinRep and hasMinFaction) and (belowMaxRep and hasMaxFaction))) then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet reputation requirements for", questId) end

            --- If we haven't got the faction for min or max we blacklist it
            if not hasMinFaction or not hasMaxFaction then -- or not belowMaxRep -- This is something we could have done, but would break if you rep downwards
                QuestieQuest.autoBlacklist[questId] = "rep"
            end

            return false
        end
    end

    local requiredSkill = QuestieDB.QueryQuestSingle(questId, "requiredSkill")
    if (requiredSkill) then
        local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
        if (not (hasProfession and hasSkillLevel)) then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet profession requirements for", questId) end
            --? We haven't got the profession so we blacklist it.
            if(not hasProfession) then
                QuestieQuest.autoBlacklist[questId] = "skill"
            end

            return false
        end
    end

    --? PreQuestGroup and PreQuestSingle are mutualy exclusive to eachother and preQuestSingle is more prevalent
    --? Only try group if single does not exist.
    if not preQuestSingle then
        -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
        local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
        if preQuestGroup ~= nil then
            local isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
            if not isPreQuestGroupFulfilled then
                if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] preQuestGroup requirement not fulfilled for questId:", questId) end

                return false
            end
        end
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest and parentQuest ~= 0 then
        local isParentQuestActive = QuestieDB.IsParentQuestActive(parentQuest)
        -- If the quest has a parent quest then only show it if the
        -- parent quest is in the quest log
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] isParentQuestActive:", isParentQuestActive) end
        return isParentQuestActive
    end

    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    if nextQuestInChain and nextQuestInChain ~= 0 then
        if Questie.db.char.complete[nextQuestInChain] or QuestiePlayer.currentQuestlog[nextQuestInChain] then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Follow up quests already completed or in the quest log!") end

            return false
        end
    end

    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    local ExclusiveQuestGroup = QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
    if ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for _, v in pairs(ExclusiveQuestGroup) do
            if Questie.db.char.complete[v] or QuestiePlayer.currentQuestlog[v] then
                if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] we have completed a quest that locks out this quest!") end

                return false
            end
        end
    end

    if (not DailyQuests:IsActiveDailyQuest(questId)) then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] quest is a daily quest not active today!") end
        return false
    end

    local requiredSpecialization = QuestieDB.QueryQuestSingle(questId, "requiredSpecialization")
    if (requiredSpecialization) and (requiredSpecialization > 0) then
        local hasSpecialization = QuestieProfessions:HasSpecialization(requiredSpecialization)
        if (not hasSpecialization) then
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet spell requirements for", questId) end
            return false
        end
    end

    local requiredSpell = QuestieDB.QueryQuestSingle(questId, "requiredSpell")
    if (requiredSpell) and (requiredSpell ~= 0) then
        local hasSpell = IsSpellKnownOrOverridesKnown(math.abs(requiredSpell))
        if (requiredSpell > 0) and (not hasSpell) then --if requiredSpell is positive, we make the quest ineligible if the player does NOT have the spell
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet spell requirements for", questId) end
            return false
        elseif (requiredSpell < 0) and hasSpell then --if requiredSpell is negative, we make the quest ineligible if the player DOES  have the spell
            if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet spell requirements for", questId) end
            return false
        end
    end

    -- Check and see if the Quest requires an achievement before showing as available
    if _QuestieDB:CheckAchievementRequirements(questId) == false then
        if debugPrint then Questie:Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet achievement requirements for", questId) end
        return false
    end

    return true
end

---@param questId number
---@return number @Complete = 1, Failed = -1, Incomplete = 0
function QuestieDB.IsComplete(questId)
    local questLogEntry = QuestLogCache.questLog_DO_NOT_MODIFY[questId] -- DO NOT MODIFY THE RETURNED TABLE
    --[[ pseudo:
    if no questLogEntry then return 0
    if has questLogEntry.isComplete then return questLogEntry.isComplete
    if no objectives then return 1
    return 0
    ]]--
    return questLogEntry and (questLogEntry.isComplete or (questLogEntry.objectives[1] and 0) or 1) or 0
end

---@param self Quest
---@return number @Complete = 1, Failed = -1, Incomplete = 0
function _QuestieDB._QO_IsComplete(self)
    return QuestieDB.IsComplete(self.Id)
end

---@return boolean @Returns true if the quest should be grey, false otherwise
local function _IsTrivial(self)
    local levelDiff = self.level - QuestiePlayer.GetPlayerLevel();
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
    return Questie.db.global.objectScale or 1
end

---@param questId QuestId
---@return Quest|nil @The quest object or nil if the quest is missing
function QuestieDB:GetQuest(questId) -- /dump QuestieDB:GetQuest(867)
    if not questId then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetQuest] No questId.")
        return nil
    end
    if _QuestieDB.questCache[questId] ~= nil then
        return _QuestieDB.questCache[questId];
    end

    local rawdata = QuestieDB.QueryQuest(questId, QuestieDB._questAdapterQueryOrder)

    if (not rawdata) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetQuest] rawdata is nil for questID:", questId)
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
    local startedBy = rawdata[questKeys.startedBy]
    QO.Starts = {
        NPC = startedBy[1],
        GameObject = startedBy[2],
        Item = startedBy[3],
    }
    QO.isHidden = rawdata.hidden or QuestieCorrections.hiddenQuests[questId]
    QO.Description = rawdata[questKeys.objectivesText]
    if QO.specialFlags then
        QO.IsRepeatable = mod(QO.specialFlags, 2) == 1
    end

    QO.IsComplete = _QuestieDB._QO_IsComplete

    ---@type FinishedBy
    local finishedBy = rawdata[questKeys.finishedBy]
    if finishedBy[1] ~= nil then
        for _, id in pairs(finishedBy[1]) do
            if id ~= nil then
                QO.Finisher = {
                    Type = "monster",
                    Id = id,
                    ---@type Name @We have to hard-type it here because of the function
                    Name = QuestieDB.QueryNPCSingle(id, "name")
                }
            end
        end
    end
    if finishedBy[2] ~= nil then
        for _, id in pairs(finishedBy[2]) do
            if id ~= nil then
                QO.Finisher = {
                    Type = "object",
                    Id = id,
                    ---@type Name @We have to hard-type it here because of the function
                    Name = QuestieDB.QueryObjectSingle(id, "name")
                }
            end
        end
    end

    --- to differentiate from the current quest log info.
    --- Quest objectives generated from DB+Corrections.
    --- Data itself is for example for monster type { Type = "monster", Id = 16518, Text = "Nestlewood Owlkin inoculated" }
    ---@type Objective[]
    QO.ObjectiveData = {}

    ---@type RawObjectives
    local objectives = rawdata[questKeys.objectives]
    if objectives ~= nil then
        if objectives[1] ~= nil then
            for _, creatureObjective in pairs(objectives[1]) do
                if creatureObjective ~= nil then
                    ---@type NpcObjective
                    local obj = {
                        Type = "monster",
                        Id = creatureObjective[1],
                        Text = creatureObjective[2]
                    }
                    tinsert(QO.ObjectiveData, obj);
                end
            end
        end
        if objectives[2] ~= nil then
            for _, objectObjective in pairs(objectives[2]) do
                if objectObjective ~= nil then
                    ---@type ObjectObjective
                    local obj = {
                        Type = "object",
                        Id = objectObjective[1],
                        Text = objectObjective[2]
                    }
                    tinsert(QO.ObjectiveData, obj);
                end
            end
        end
        if objectives[3] ~= nil then
            for _, itemObjective in pairs(objectives[3]) do
                if itemObjective ~= nil then
                    ---@type ItemObjective
                    local obj = {
                        Type = "item",
                        Id = itemObjective[1],
                        Text = itemObjective[2]
                    }
                    tinsert(QO.ObjectiveData, obj);
                end
            end
        end
        if objectives[4] ~= nil then
            ---@type ReputationObjective
            local reputationObjective = {
                Type = "reputation",
                Id = objectives[4][1],
                RequiredRepValue = objectives[4][2]
            }
            tinsert(QO.ObjectiveData, reputationObjective);
        end
        if objectives[5] ~= nil and type(objectives[5]) == "table" and #objectives[5] > 0 then
            for _, creditObjective in pairs(objectives[5]) do
                ---@type KillObjective
                local killCreditObjective = {
                    Type = "killcredit",
                    IdList = creditObjective[1],
                    RootId = creditObjective[2],
                    Text = creditObjective[3]
                }

                --? There are quest(s) which have the killCredit at first so we need to switch them
                -- Place the kill credit objective first
                if QuestieCorrections.killCreditObjectiveFirst[questId] then
                    tinsert(QO.ObjectiveData, 1, killCreditObjective);
                else
                    tinsert(QO.ObjectiveData, killCreditObjective);
                end
            end
        end
    end

    -- Events need to be added at the end of ObjectiveData
    local triggerEnd = rawdata[questKeys.triggerEnd]
    if triggerEnd then
        ---@type TriggerEndObjective
        local obj = {
            Type = "event",
            Text = triggerEnd[1],
            Coordinates = triggerEnd[2]
        }
        tinsert(QO.ObjectiveData, obj);
    end

    local preQuestGroup = rawdata[questKeys.preQuestGroup]
    local preQuestSingle = rawdata[questKeys.preQuestSingle]
    if(preQuestGroup ~= nil and next(preQuestGroup) ~= nil and preQuestSingle ~= nil and next(preQuestSingle) ~= nil) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "ERRRRORRRRRRR not mutually exclusive for questID:", questId)
    end

    --- Quest objectives generated from quest log in QuestieQuest.lua -> QuestieQuest:PopulateQuestLogInfo(quest)
    --- Includes also icons drawn to maps, and other stuff.
    ---@type table<ObjectiveIndex, QuestObjective>
    QO.Objectives = {}

    QO.SpecialObjectives = {}

    ---@type ItemId[]
    local requiredSourceItems = rawdata[questKeys.requiredSourceItems]
    if requiredSourceItems ~= nil then --required source items
        for _, itemId in pairs(requiredSourceItems) do
            if itemId ~= nil then
                QO.SpecialObjectives[itemId] = {
                    Type = "item",
                    Id = itemId,
                    ---@type string @We have to hard-type it here because of the function
                    Description = QuestieDB.QueryItemSingle(itemId, "name")
                }
            end
        end
    end

    local zoneOrSort = rawdata[questKeys.zoneOrSort]
    if zoneOrSort and zoneOrSort ~= 0 then
        if zoneOrSort > 0 then
            QO.Zone = zoneOrSort
        else
            QO.Sort = -zoneOrSort
        end
    end

    QO.IsTrivial = _IsTrivial

    ---@type ExtraObjective[]
    local extraObjectives = rawdata[questKeys.extraObjectives]
    if extraObjectives then
        for index, o in pairs(extraObjectives) do
            QO.SpecialObjectives[index] = {
                Icon = o[2],
                Description = o[3],
                RealObjectiveIndex = o[4],
            }
            if o[1] then -- custom spawn
                QO.SpecialObjectives[index].spawnList = {{
                    Name = o[3],
                    Spawns = o[1],
                    Icon = o[2],
                    GetIconScale = _GetIconScale,
                    IconScale = _GetIconScale(),
                }}
            end
            if o[5] then -- db ref
                QO.SpecialObjectives[index].Type = o[5][1][1]
                QO.SpecialObjectives[index].Id = o[5][1][2]
                local spawnList = {}

                for _, ref in pairs(o[5]) do
                    for k, v in pairs(_QuestieQuest.objectiveSpawnListCallTable[ref[1]](ref[2], QO.SpecialObjectives[index])) do
                        -- we want to be able to override the icon in the corrections (e.g. Questie.ICON_TYPE_OBJECT on objects instead of Questie.ICON_TYPE_LOOT)
                        v.Icon = o[2]
                        spawnList[k] = v
                    end
                end

                QO.SpecialObjectives[index].spawnList = spawnList
            end
        end
    end

    _QuestieDB.questCache[questId] = QO
    return QO
end

QuestieDB._CreatureLevelCache = {}
---@param quest Quest
---@return table<string, table> @List of creature names with their min-max level and rank
function QuestieDB:GetCreatureLevels(quest)
    if quest and quest.Id and QuestieDB._CreatureLevelCache[quest.Id] then
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
                local npcIdff = creatureObjective[2]
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

local playerFaction = UnitFactionGroup("player")

---@param npcId number
---@return table
function QuestieDB:GetNPC(npcId)
    if not npcId then
        return nil
    end
    if(_QuestieDB.npcCache[npcId]) then
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
    if friendlyToFaction then
        if friendlyToFaction == "AH" then
            npc.friendly = true
        else
            if playerFaction == "Horde" and friendlyToFaction == "H" then
                npc.friendly = true
            elseif playerFaction == "Alliance" and friendlyToFaction == "A" then
                npc.friendly = true
            end
        end
    else
        npc.friendly = true
    end

    return npc
end

--[[
    https://github.com/cmangos/issues/wiki/AreaTable.dbc
    Example to differentiate between Dungeon and Zone infront of a Dungeon:
    1337 Uldaman = The Dungeon (MapID ~= 0, AreaID = 0)
    1517 Uldaman = Cave infront of the Dungeon (MapID = 0, AreaID = 3 (Badlands))

    Check `l10n.zoneLookup` for the available IDs
]]
---@param zoneId number
---@return table
function QuestieDB:GetQuestsByZoneId(zoneId)
    if not zoneId then
        return nil;
    end
    -- is in cache return that
    if _QuestieDB.zoneCache[zoneId] then
        return _QuestieDB.zoneCache[zoneId]
    end
    local zoneQuests = {};
    local alternativeZoneID = ZoneDB:GetAlternativeZoneId(zoneId)
    -- loop over all quests to populate a zone
    for qid, _ in pairs(QuestieDB.QuestPointers or QuestieDB.questData) do
        local quest = QuestieDB:GetQuest(qid);
        if quest then
            if quest.zoneOrSort > 0 then
                if (quest.zoneOrSort == zoneId or (alternativeZoneID and quest.zoneOrSort == alternativeZoneID)) then
                    zoneQuests[qid] = quest;
                end
            elseif quest.Starts.NPC and (not zoneQuests[qid]) then
                local npc = QuestieDB:GetNPC(quest.Starts.NPC[1]);
                if npc and npc.friendly and npc.spawns then
                    for zone, _ in pairs(npc.spawns) do
                        if zone == zoneId  or (alternativeZoneID and zone == alternativeZoneID) then
                            zoneQuests[qid] = quest;
                        end
                    end
                end
            elseif quest.Starts.GameObject and (not zoneQuests[qid]) then
                local obj = QuestieDB:GetObject(quest.Starts.GameObject[1]);
                if obj and obj.spawns then
                    for zone, _ in pairs(obj.spawns) do
                        if zone == zoneId  or (alternativeZoneID and zone == alternativeZoneID) then
                            zoneQuests[qid] = quest;
                        end
                    end
                end
            end
        end
    end
    _QuestieDB.zoneCache[zoneId] = zoneQuests;
    return zoneQuests;
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
            else
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
            else
                Questie:Error("Database mismatch! No entries found that match quest name. Please report this on Github or Discord!")
                Questie:Error("Questender is: " .. unit_type .. " " .. questgiverID)
                Questie:Error("Quest name is: " .. name)
                Questie:Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
            end
        end
    end
    return questID;
end

QuestieDB.waypointPresets = {
    ORGRIMS_HAMMER = {[ZoneDB.zoneIDs.ICECROWN]={{{62.37,30.60},{61.93,30.93},{61.48,31.24},{61.08,31.55},{60.74,31.92},{60.46,32.44},{60.26,33.11},{60.14,33.85},{60.11,34.63},{60.17,35.35},{60.31,36.01},{60.56,36.66},{60.84,37.33},{61.15,38.00},{61.44,38.67},{61.71,39.28},{62.00,39.92},{62.31,40.55},{62.60,41.20},{62.90,41.83},{63.05,42.20},{63.33,42.85},{63.58,43.53},{63.85,44.19},{64.08,44.86},{64.33,45.50},{64.45,45.87},{64.69,46.56},{64.94,47.21},{65.16,47.87},{65.43,48.51},{65.71,49.15},{66.03,49.77},{66.36,50.46},{66.72,51.10},{67.07,51.67},{67.41,52.08},{67.82,52.37},{68.31,52.47},{68.80,52.38},{69.23,51.98},{69.45,51.56},{69.57,51.13},{69.67,50.59},{69.73,49.96},{69.77,49.26},{69.79,48.48},{69.80,47.62},{69.79,46.68},{69.79,45.68},{69.78,44.90},{69.78,44.25},{69.76,43.55},{69.75,42.80},{69.72,42.01},{69.70,41.20},{69.67,40.38},{69.64,39.54},{69.61,38.71},{69.58,37.88},{69.55,37.07},{69.52,36.28},{69.49,35.54},{69.46,34.83},{69.45,34.18},{69.42,33.50},{69.41,32.46},{69.42,31.52},{69.45,30.67},{69.47,29.92},{69.48,29.25},{69.46,28.65},{69.42,28.12},{69.35,27.83},{69.11,27.19},{68.71,26.77},{68.23,26.54},{67.71,26.51},{67.24,26.55},{66.81,26.76},{66.35,27.09},{65.90,27.52},{65.44,27.95},{65.01,28.39},{64.58,28.73},{64.16,29.10},{63.74,29.43},{63.34,29.79},{62.94,30.11},{62.65,30.37},{62.37,30.60}}}},
}
