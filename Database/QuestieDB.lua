---@class QuestieDB
local QuestieDB = QuestieLoader:CreateModule("QuestieDB")
local _QuestieDB = QuestieDB.private

-------------------------
--Import modules.
-------------------------
---@type QuestieStreamLib
local QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type DBCompiler
local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

local tinsert = table.insert


-- DB keys
local DB_OBJ_SPAWNS = 4
local DB_NPC_FRIENDLY = 13


--- Tag corrections for quests for which the API returns the wrong values.
--- Strucute: [questId] = {tagId, "questType"}
---@type table<number, table<number, string>>
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

_QuestieDB.questCache = {}; -- stores quest objects so they dont need to be regenerated
_QuestieDB.itemCache = {};
_QuestieDB.npcCache = {};
_QuestieDB.objectCache = {};
_QuestieDB.zoneCache = {};

QuestieDB.itemDataOverrides = {}
QuestieDB.npcDataOverrides = {}
QuestieDB.objectDataOverrides = {}
QuestieDB.questDataOverrides = {}

function QuestieDB:Initialize()
    _QuestieDB:DeleteGatheringNodes() -- todo: do this before db compile

    QuestieDB.QueryNPC = QuestieDBCompiler:GetDBHandle(QuestieConfig.npcBin, QuestieConfig.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder), QuestieDB.npcKeys, QuestieDB.npcDataOverrides)
    QuestieDB.QueryQuest = QuestieDBCompiler:GetDBHandle(QuestieConfig.questBin, QuestieConfig.questPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder), QuestieDB.questKeys, QuestieDB.questDataOverrides)
    QuestieDB.QueryObject = QuestieDBCompiler:GetDBHandle(QuestieConfig.objBin, QuestieConfig.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder), QuestieDB.objectKeys, QuestieDB.objectDataOverrides)
    QuestieDB.QueryItem = QuestieDBCompiler:GetDBHandle(QuestieConfig.itemBin, QuestieConfig.itemPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder), QuestieDB.itemKeys, QuestieDB.itemDataOverrides)

    QuestieDB.QueryQuestSingle = QuestieDB.QueryQuest.QuerySingle
    QuestieDB.QueryNPCSingle = QuestieDB.QueryNPC.QuerySingle
    QuestieDB.QueryObjectSingle = QuestieDB.QueryObject.QuerySingle
    QuestieDB.QueryItemSingle = QuestieDB.QueryItem.QuerySingle

    QuestieDB.NPCPointers = QuestieDB.QueryNPC.pointers
    QuestieDB.QuestPointers = QuestieDB.QueryQuest.pointers
    QuestieDB.ObjectPointers = QuestieDB.QueryObject.pointers
    QuestieDB.ItemPointers = QuestieDB.QueryItem.pointers

    QuestieDB.QueryNPC = QuestieDB.QueryNPC.Query
    QuestieDB.QueryQuest = QuestieDB.QueryQuest.Query
    QuestieDB.QueryObject = QuestieDB.QueryObject.Query
    QuestieDB.QueryItem = QuestieDB.QueryItem.Query

    -- data has been corrected, ensure cache is empty (something might have accessed the api before questie initialized)
    _QuestieDB.questCache = {};
    _QuestieDB.itemCache = {};
    _QuestieDB.npcCache = {};
    _QuestieDB.objectCache = {};
    _QuestieDB.zoneCache = {};
end

function QuestieDB:GetObject(objectId)
    if objectId == nil then
        return nil
    end
    if _QuestieDB.objectCache[objectId] ~= nil then
        return _QuestieDB.objectCache[objectId];
    end

    --local rawdata = QuestieDB.objectData[objectId];
    local rawdata = QuestieDB.QueryObject(objectId, unpack(QuestieDB._objectAdapterQueryOrder))

    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetObject] rawdata is nil for objectID:", objectId)
        return nil
    end

    local obj = {};

    obj.id = objectId
    obj.type = "object"
    for stringKey, intKey in pairs(QuestieDB.objectKeys) do
        obj[stringKey] = rawdata[intKey]
    end
    --_QuestieDB.objectCache[objectId] = obj;
    return obj;
end

function QuestieDB:GetItem(itemId)
    if itemId == nil  or itemId == 0 then
        return nil
    end
    if _QuestieDB.itemCache[itemId] ~= nil then
        return _QuestieDB.itemCache[itemId];
    end

    --local rawdata = QuestieDB.itemData[itemId]; -- TODO: use the good item db, I need to talk to Muehe about the format, this is a temporary fix
    --print("queryitem: " .. itemId)
    local rawdata = QuestieDB.QueryItem(itemId, unpack(QuestieDB._itemAdapterQueryOrder))

    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetItem] rawdata is nil for itemID:", itemId)
        return nil
    end

    local item = {};

    for stringKey, intKey in pairs(QuestieDB.itemKeys) do
        item[stringKey] = rawdata[intKey]
    end

    item.Id = itemId;
    item.Sources = {};
    item.Hidden = QuestieCorrections.questItemBlacklist[itemId]
    if rawdata[3] then
        for _, v in pairs(rawdata[3]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
            local source = {};
            source.Type = "monster";
            source.Id = v;
            tinsert(item.Sources, source);
        end
    end
    if rawdata[4] then
        for _, v in pairs(rawdata[4]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
            local source = {};
            source.Type = "object";
            source.Id = v;
            tinsert(item.Sources, source);
        end
    end
    --_QuestieDB.itemCache[itemId] = item;
    return item
end

local function _GetColoredQuestName(self, blizzLike)
    local questName = (self.LocalizedName or self.name)
    return QuestieLib:GetColoredQuestName(self.Id, questName, self.level, Questie.db.global.enableTooltipsQuestLevel, false, blizzLike)
end

function QuestieDB:GetColoredQuestName(id, blizzLike)
    local questName, level = unpack(QuestieDB.QueryQuest(id, "name", "questLevel"))
    return QuestieLib:GetColoredQuestName(id, questName, level, Questie.db.global.enableTooltipsQuestLevel, false, blizzLike)
end

-- TODO: move these into a QuestUtils class or something
function QuestieDB:IsRepeatable(id)
    local flags = QuestieDB.QueryQuestSingle(id, "specialFlags")
    return flags and mod(flags, 2) == 1
end

function QuestieDB:IsDungeonQuest(questId)
    local questType, _ = QuestieDB:GetQuestTagInfo(questId)
    return questType == 81
end

function QuestieDB:IsRaidQuest(questId)
    local questType, _ = QuestieDB:GetQuestTagInfo(questId)
    return questType == 62
end

function QuestieDB:IsPvPQuest(questId)
    local questType, _ = QuestieDB:GetQuestTagInfo(questId)
    return questType == 41
end

__TEST = function(id) return QuestieDB:IsAQWarEffortQuest(id) end

function QuestieDB:IsAQWarEffortQuest(questId)
    return QuestieQuestBlacklist:GetAQWarEffortQuests()[questId] == true
end

--- Wrapper function for the GetQuestTagInfo API to correct
--- quests that are falsely marked by Blizzard
function QuestieDB:GetQuestTagInfo(questId)
    local questType, questTag = GetQuestTagInfo(questId)

    if questTagCorrections[questId] then
        questType = questTagCorrections[questId][1]
        questTag = questTagCorrections[questId][2]
    end

    return questType, questTag
end

--@param quest QuestieQuest @The quest to check for completion
--@return integer @Complete = 1, Failed = -1, Incomplete = 0
function QuestieDB:IsComplete(questId)
    local questLogIndex = GetQuestLogIndexByID(questId)
    local _, _, _, _, _, isComplete, _, _, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(questLogIndex)

    if isComplete ~= nil then
        return isComplete -- 1 if the quest is completed, -1 if the quest is failed
    end

    isComplete = IsQuestComplete(questId) -- true if the quest is both in the quest log and complete, false otherwise
    if isComplete then
        return 1
    end

    return 0
end

function QuestieDB:IsRepeatable(questId)
    local specialFlags = unpack(QuestieDB.QueryQuest(questId, "specialFlags"))
    return mod(specialFlags, 2) == 1
end

function QuestieDB:IsActiveEventQuest(questId)
    return QuestieEvent.activeQuests[questId] == true
end

function QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)
    for _, exId in pairs(exclusiveTo) do
        if Questie.db.char.complete[exId] then
            return true
        end
    end
    return false
end

function QuestieDB:IsLevelRequirementsFulfilled(questId, minLevel, maxLevel)
    local level, requiredLevel = unpack(QuestieDB.QueryQuest(questId, "questLevel", "requiredLevel"))

    if QuestieDB:IsActiveEventQuest(questId) and minLevel > requiredLevel and (not Questie.db.char.absoluteLevelOffset) then
        return true
    end
    -- Questie.db.char.absoluteLevelOffset
    if maxLevel >= level then
        if minLevel > level and (not Questie.db.char.lowlevel) then
            return false
        end
    else
        if maxLevel < requiredLevel or Questie.db.char.absoluteLevelOffset then
            return false
        end
    end

    return true
end

function QuestieDB:IsParentQuestActive(parentID)
    if parentID == nil or parentID == 0 then
        return false
    end
    if QuestiePlayer.currentQuestlog[parentID] then
        return true
    end
    return false
end

function QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
    if not preQuestGroup or not next(preQuestGroup) then
        return true
    end
    for _, preQuestId in pairs(preQuestGroup) do
        -- If a quest is not complete and no exlusive quest is complete, the requirement is not fulfilled
        if not Questie.db.char.complete[preQuestId] then
            local preQuest = QuestieDB:GetQuest(preQuestId);
            if preQuest == nil or preQuest.ExclusiveQuestGroup == nil then
                return false
            end

            local anyExlusiveFinished = false
            for _, v in pairs(preQuest.ExclusiveQuestGroup) do
                if Questie.db.char.complete[v] then
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

function QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
    if not preQuestSingle or not next(preQuestSingle) then
        return true
    end
    for _, preQuestId in pairs(preQuestSingle) do
        -- If a quest is complete the requirement is fulfilled
        if Questie.db.char.complete[preQuestId] then
            return true
        -- If one of the quests in the exclusive group is complete the requirement is fulfilled
        else
            local preQuestExclusiveQuestGroup = QuestieDB.QueryQuestSingle(preQuestId, "exclusiveTo")
            if preQuestExclusiveQuestGroup then
                for _, v in pairs(preQuestExclusiveQuestGroup) do
                    if Questie.db.char.complete[v] then
                        return true
                    end
                end
            end
        end
    end
    -- No preQuest is complete
    return false
end

function QuestieDB:IsDoable(questId)

    if QuestieCorrections.hiddenQuests[questId] then
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] quest is hidden!")
        return false
    end

    if Questie.db.char.hidden[questId] then
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] quest is hidden manually!")
        return false
    end

    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")

    if (not QuestiePlayer:HasRequiredRace(requiredRaces)) then
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] race requirement not fulfilled for questId: " .. questId)
        return false
    end

    local requiredClasses = QuestieDB.QueryQuestSingle(questId, "requiredClasses")

    if (not QuestiePlayer:HasRequiredClass(requiredClasses)) then
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] class requirement not fulfilled for questId: " .. questId)
        return false
    end

    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")

    if nextQuestInChain and nextQuestInChain ~= 0 then
        if Questie.db.char.complete[nextQuestInChain] or QuestiePlayer.currentQuestlog[nextQuestInChain] then
            Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] part of a chain we dont have!")
            return false
        end
    end
    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    local ExclusiveQuestGroup = QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
    if ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for k, v in pairs(ExclusiveQuestGroup) do
            if Questie.db.char.complete[v] or QuestiePlayer.currentQuestlog[v] then
                Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] we have completed a quest that locks out this quest!")
                return false
            end
        end
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")

    if parentQuest and parentQuest ~= 0 then
        local isParentQuestActive = QuestieDB:IsParentQuestActive(parentQuest)
        -- If the quest has a parent quest then only show it if the
        -- parent quest is in the quest log
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] isParentQuestActive:", isParentQuestActive)
        return isParentQuestActive
    end

    local requiredSkill = QuestieDB.QueryQuestSingle(questId, "requiredSkill")

    if (not QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)) then
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] Player does not meet profession requirements for", questId)
        return false
    end

    local requiredMinRep = QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    local requiredMaxRep = QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")

    if (not QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep)) then
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] Player does not meet reputation requirements for", questId)
        return false
    end

    local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")

    -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
    if preQuestGroup ~= nil and next(preQuestGroup) ~= nil then
        local isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] isPreQuestGroupFulfilled", isPreQuestGroupFulfilled)
        return isPreQuestGroupFulfilled
    end

    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    if preQuestSingle ~= nil and next(preQuestSingle) ~= nil then
        local isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
        Questie:Debug(DEBUG_INFO, "[QuestieDB:IsDoable] isPreQuestSingleFulfilled", isPreQuestSingleFulfilled)
        return isPreQuestSingleFulfilled
    end

    return true
end



---@param questId QuestId @The quest ID
---@return Quest|nil @The quest object or nil if the quest is missing
function QuestieDB:GetQuest(questId) -- /dump QuestieDB:GetQuest(867)
    if questId == nil then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetQuest] Expected questID but received nil!")
        return nil
    end
    if _QuestieDB.questCache[questId] ~= nil then
        return _QuestieDB.questCache[questId];
    end

    --local rawdata = QuestieDB.questData[questId];
    local rawdata = QuestieDB.QueryQuest(questId, unpack(QuestieDB._questAdapterQueryOrder))

    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetQuest] rawdata is nil for questID:", questId)
        return nil
    end

    ---@class ObjectiveIndex
    ---@class QuestId

    ---@class Quest
    ---@field public childQuests any
    ---@field public exclusiveTo any
    ---@field public finishedBy any
    ---@field public inGroupWith any
    ---@field public name string
    ---@field public nextQuestInChain any
    ---@field public objectives any
    ---@field public objectivesText any
    ---@field public parentQuest any
    ---@field public preQuestGroup any
    ---@field public preQuestSingle any
    ---@field public questLevel any
    ---@field public requiredClasses any
    ---@field public requiredLevel any
    ---@field public requiredMinRep any
    ---@field public requiredRaces any
    ---@field public requiredSkill any
    ---@field public requiredSourceItems any
    ---@field public sourceItemId any
    ---@field public specialFlags any
    ---@field public startedBy any
    ---@field public triggerEnd any
    ---@field public zoneOrSort any

    local QO = {}
    QO.GetColoredQuestName = _GetColoredQuestName
    QO.Id = questId --Key
    for stringKey, intKey in pairs(QuestieDB.questKeys) do
        QO[stringKey] = rawdata[intKey]
    end
    QO.Starts = {} --Starts - 2
    QO.Starts["NPC"] = rawdata[2][1] --2.1
    QO.Starts["GameObject"] = rawdata[2][2] --2.2
    QO.Starts["Item"] = rawdata[2][3] --2.3
    QO.Ends = {} --ends 3
    QO.isHidden = rawdata.hidden or QuestieCorrections.hiddenQuests[questId]
    QO.Description = rawdata[8] --
    if QO.specialFlags then
        QO.IsRepeatable = mod(QO.specialFlags, 2) == 1
    end

    -- This function is required because direct calls of GetQuestTagInfo while
    -- initializing the quest object either returns false values or will make the
    -- quest log appear empty
    function QO:IsDungeonQuest()
        local questType, _ = self:GetQuestTagInfo()
        return questType == 81
    end

    function QO:IsRaidQuest()
        local questType, _ = self:GetQuestTagInfo()
        return questType == 62
    end

    function QO:IsPvPQuest()
        local questType, _ = self:GetQuestTagInfo()
        return questType == 41
    end

    function QO:IsActiveEventQuest()
        return QuestieEvent.activeQuests[self.Id] == true
    end

    function QO:IsAQWarEffortQuest()
        return QuestieQuestBlacklist:GetAQWarEffortQuests()[self.Id] == true
    end

    --- Wrapper function for the GetQuestTagInfo API to correct
    --- quests that are falsely marked by Blizzard
    function QO:GetQuestTagInfo()
        local questType, questTag = GetQuestTagInfo(self.Id)

        if questTagCorrections[self.Id] then
            questType = questTagCorrections[self.Id][1]
            questTag = questTagCorrections[self.Id][2]
        end

        return questType, questTag
    end

    --@param quest QuestieQuest @The quest to check for completion
    --@return integer @Complete = 1, Failed = -1, Incomplete = 0
    function QO:IsComplete()
        local questLogIndex = GetQuestLogIndexByID(self.Id)
        local _, _, _, _, _, isComplete, _, _, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(questLogIndex)

        if isComplete ~= nil then
            return isComplete -- 1 if the quest is completed, -1 if the quest is failed
        end

        isComplete = IsQuestComplete(self.Id) -- true if the quest is both in the quest log and complete, false otherwise
        if isComplete then
            return 1
        end

        return 0
    end

    function QO:IsLevelRequirementsFulfilled(minLevel, maxLevel)

        if self:IsActiveEventQuest() and minLevel > self.requiredLevel then
            return true
        end

        if maxLevel >= self.level then
            if minLevel > self.level and (not Questie.db.char.lowlevel) then
                return false
            end
        else
            if maxLevel < self.requiredLevel then
                return false
            end
        end

        return true
    end

    function QO:IsDoable() -- temporary
        return QuestieDB:IsDoable(self.Id)
    end

    -- We always want to show a quest if it is a childQuest and its parent is in the quest log
    function QO:IsParentQuestActive()
        local parentID = self.parentID
        if parentID == nil or parentID == 0 then
            return false
        end
        if QuestiePlayer.currentQuestlog[parentID] then
            return true
        end
        return false
    end

    -- reorganize to match wow api
    if rawdata[3][1] ~= nil then
        for _, v in pairs(rawdata[3][1]) do
            if v ~= nil then
                local obj = {};
                obj.Type = "monster"
                obj.Id = v

                -- this speeds up lookup
                obj.Name = QuestieDB.QueryNPCSingle(v, "name")--QuestieDB.npcData[v]
                if obj.Name ~= nil then
                    --local name = obj.Name[QuestieDB.npcKeys.name]
                    obj.Name = string.lower(obj.Name);
                end

                QO.Finisher = obj; -- there is only 1 finisher --tinsert(QO.Finisher, obj);
            end
        end
    end
    if rawdata[3][2] ~= nil then
        for _, v in pairs(rawdata[3][2]) do
            if v ~= nil then
                local obj = {};
                obj.Type = "object"
                obj.Id = v

                -- this speeds up lookup
                obj.Name = QuestieDB.QueryObjectSingle(v, "name")--QuestieDB.objectData[v]
                if obj.Name ~= nil then
                    obj.Name = string.lower(obj.Name)--string.lower(obj.Name[1]);
                end

                QO.Finisher = obj; -- there is only 1 finisher
            end
        end
    end

    QO.level = rawdata[5]
    QO.Triggers = rawdata[9] --List of coordinates
    QO.ObjectiveData = {} -- to differentiate from the current quest log info
    --    type
    --String - could be the following things: "item", "object", "monster", "reputation", "log", or "event". (from wow api)

    if QO.Triggers ~= nil then
        for _, v in pairs(QO.Triggers) do
            local obj = {};
            obj.Type = "event"
            obj.Coordinates = v
            tinsert(QO.ObjectiveData, obj);
        end
    end
    if rawdata[10] ~= nil then
        if rawdata[10][1] ~= nil then
            for _, v in pairs(rawdata[10][1]) do
                if v ~= nil then

                    local obj = {};
                    obj.Type = "monster"
                    obj.Id = v[1]
                    obj.Text = v[2];

                    tinsert(QO.ObjectiveData, obj);

                end
            end
        end
        if rawdata[10][2] ~= nil then
            for _, v in pairs(rawdata[10][2]) do
                if v ~= nil then

                    local obj = {};
                    obj.Type = "object"
                    obj.Id = v[1]
                    obj.Text = v[2]

                    tinsert(QO.ObjectiveData, obj);

                end
            end
        end
        if rawdata[10][3] ~= nil then
            for _, v in pairs(rawdata[10][3]) do
                if v ~= nil then
                    local obj = {};
                    obj.Type = "item"
                    obj.Id = v[1]
                    obj.Text = v[2]

                    tinsert(QO.ObjectiveData, obj);
                end
            end
        end
    end

    if(rawdata[12] ~= nil and next(rawdata[12]) ~= nil and rawdata[13] ~= nil and next(rawdata[13]) ~= nil) then
        Questie:Debug(DEBUG_CRITICAL, "ERRRRORRRRRRR not mutually exclusive for questID:", questId)
    end
    QO.QuestGroup = rawdata[15] --Quests that are part of the same group, example complete this group of quests to open the next one.
    QO.ExclusiveQuestGroup = rawdata[16]

    QO.HiddenObjectiveData = {}

    local hidden = rawdata[21]

    if hidden ~= nil then --required source items
        for _, id in pairs(hidden) do
            if id ~= nil then

                local obj = {};
                obj.Type = "item"
                obj.Id = id

                obj.Name = QuestieDB.QueryItemSingle(id, "name")--QuestieDB.itemData[obj.Id]
                if obj.Name ~= nil then
                    --local name = obj.Name[QuestieDB.itemKeys.name]
                    obj.Name = string.lower(obj.Name);
                end

                tinsert(QO.HiddenObjectiveData, obj);
            end
        end
    end

    local zos = rawdata[17]
    if zos and zos ~= 0 then
        if zos > 0 then
            QO.Zone = zos
        else
            QO.Sort = -zos
        end
    end

    --- function
    ---@return boolean @Returns true if the quest should be grey, false otherwise
    function QO:IsTrivial()
        local levelDiff = self.level - QuestiePlayer:GetPlayerLevel();
        if (levelDiff >= 5) then
            return false -- Red
        elseif (levelDiff >= 3) then
            return false -- Orange
        elseif (levelDiff >= -2) then
            return false -- Yellow
        elseif (-levelDiff <= GetQuestGreenRange()) then
            return false -- Green
        else
            return true -- Grey
        end
    end

    ---@return boolean @Returns true if any pre quest has been completed or none is listed, false otherwise
    function QO:IsPreQuestSingleFulfilled()
        local preQuestSingle = self.preQuestSingle
        if not preQuestSingle or not next(preQuestSingle) then
            return true
        end
        for _, preQuestId in pairs(preQuestSingle) do
            local preQuest = QuestieDB:GetQuest(preQuestId);

            -- If a quest is complete the requirement is fulfilled
            if Questie.db.char.complete[preQuestId] then
                return true
            -- If one of the quests in the exclusive group is complete the requirement is fulfilled
            elseif preQuest and preQuest.ExclusiveQuestGroup then
                for _, v in pairs(preQuest.ExclusiveQuestGroup) do
                    if Questie.db.char.complete[v] then
                        return true
                    end
                end
            end
        end
        -- No preQuest is complete
        return false
    end

    ---@return boolean @Returns true if all listed pre quests are complete or none is listed, false otherwise
    function QO:IsPreQuestGroupFulfilled()
        local preQuestGroup = self.preQuestGroup
        if not preQuestGroup or not next(preQuestGroup) then
            return true
        end
        for _, preQuestId in pairs(preQuestGroup) do
            -- If a quest is not complete and no exlusive quest is complete, the requirement is not fulfilled
            if not Questie.db.char.complete[preQuestId] then
                local preQuest = QuestieDB:GetQuest(preQuestId);
                if preQuest == nil or preQuest.ExclusiveQuestGroup == nil then
                    return false
                end

                local anyExlusiveFinished = false
                for _, v in pairs(preQuest.ExclusiveQuestGroup) do
                    if Questie.db.char.complete[v] then
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

    _QuestieDB.questCache[questId] = QO
    return QO
end

---@param quest Quest
---@return table<string, table> @List of creature names with their min-max level and rank
QuestieDB._CreatureLevelCache = {}
function QuestieDB:GetCreatureLevels(quest)
    if quest and quest.Id and QuestieDB._CreatureLevelCache[quest.Id] then
        return QuestieDB._CreatureLevelCache[quest.Id]
    end
    local creatureLevels = {}

    local function _CollectCreatureLevels(npcList)
        for index, npcId in pairs(npcList) do
            -- Some objectives are {id, name} others are just {id}
            if npcId == nil or type(npcId) == "string" then
                npcId = index
            end
            local npc = QuestieDB:GetNPC(npcId)
            if npc and not creatureLevels[npc.name] then
                creatureLevels[npc.name] = {npc.minLevel, npc.maxLevel, npc.rank}
            end
        end
    end

    if quest.objectives then
        if quest.objectives[1] then -- Killing creatures
            for _, mobObjective in pairs(quest.objectives[1]) do
                _CollectCreatureLevels(mobObjective)
            end
        end
        if quest.objectives[3] then -- Looting items from creatures
            for _, itemObjective in pairs(quest.objectives[3]) do
                local drops = QuestieDB.QueryItemSingle(itemObjective[1], "npcDrops")
                if drops then
                    _CollectCreatureLevels(drops)
                end
            end
        end
    end
    if quest.Id then
        QuestieDB._CreatureLevelCache[quest.Id] = creatureLevels
    end
    return creatureLevels
end

QuestieDB.FactionGroup = UnitFactionGroup("player")

function QuestieDB:GetNPC(npcId)
    if npcId == nil then
        return nil
    end
    if(_QuestieDB.npcCache[npcId]) then
        return _QuestieDB.npcCache[npcId]
    end

    --local rawdata = QuestieDB.npcData[npcId]
    local rawdata = QuestieDB.QueryNPC(npcId, unpack(QuestieDB._npcAdapterQueryOrder))


    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetNPC] rawdata is nil for npcID:", npcId)
        return nil
    end

    local npc = {}
    npc.type = "monster"
    npc.id = npcId
    for stringKey, intKey in pairs(QuestieDB.npcKeys) do
        npc[stringKey] = rawdata[intKey]
    end

    ---@class Point
    ---@class Zone
    if npc.waypoints == nil and rawdata[QuestieDB.npcKeys.waypoints] then
        Questie:Debug(DEBUG_DEVELOP, "Got waypoints! NPC", npc.name, npc.id)
        ---@type table<Zone, table<Point, Point>>
        npc.waypoints = rawdata[QuestieDB.npcKeys.waypoints];
    end

    if rawdata[DB_NPC_FRIENDLY] then
        if rawdata[DB_NPC_FRIENDLY] == "AH" then
            npc.friendly = true
        else
            if QuestieDB.FactionGroup == "Horde" and rawdata[DB_NPC_FRIENDLY] == "H" then
                npc.friendly = true
            elseif QuestieDB.FactionGroup == "Alliance" and rawdata[DB_NPC_FRIENDLY] == "A" then
                npc.friendly = true
            end
        end
    else
        npc.friendly = true
    end

    --_QuestieDB.npcCache[npcId] = npc
    return npc
end

--[[
    https://github.com/cmangos/issues/wiki/AreaTable.dbc
    Example to differentiate between Dungeon and Zone infront of a Dungeon:
    1337 Uldaman = The Dungeon (MapID ~= 0, AreaID = 0)
    1517 Uldaman = Cave infront of the Dungeon (MapID = 0, AreaID = 3 (Badlands))

    Check `LangZoneLookup` for the available IDs
]]
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
            elseif quest.Starts.NPC and zoneQuests[qid] == nil then
                local npc = QuestieDB:GetNPC(quest.Starts.NPC[1]);
                if npc and npc.friendly and npc.spawns then
                    for zone, _ in pairs(npc.spawns) do
                        if zone == zoneId  or (alternativeZoneID and zone == alternativeZoneID) then
                            zoneQuests[qid] = quest;
                        end
                    end
                end
            elseif quest.Starts.GameObject and zoneQuests[qid] == nil then
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
    };
    for k,v in pairs(prune) do
        QuestieDB.objectData[v][DB_OBJ_SPAWNS] = nil
    end
end

---------------------------------------------------------------------------------------------------
-- Modifications to questDB

function _QuestieDB:HideClassAndRaceQuests()
    local questKeys = QuestieDB.questKeys
    for key, entry in pairs(QuestieDB.questData) do
        -- check requirements, set hidden flag if not met
        local requiredClasses = entry[questKeys.requiredClasses]
        if (requiredClasses) and (requiredClasses ~= 0) then
            if (not QuestiePlayer:HasRequiredClass(requiredClasses)) then
                entry.hidden = true
            end
        end
        local requiredRaces = entry[questKeys.requiredRaces]
        if (requiredRaces) and (requiredRaces ~= 0) and (requiredRaces ~= 255) then
            if (not QuestiePlayer:HasRequiredRace(requiredRaces)) then
                entry.hidden = true
            end
        end
    end
    Questie:Debug(DEBUG_DEVELOP, "Other class and race quests hidden");
end
