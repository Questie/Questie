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
---@type QuestieDBZone
local QuestieDBZone = QuestieLoader:ImportModule("QuestieDBZone")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")

local tinsert = table.insert

-- DB keys
local DB_OBJ_SPAWNS = 4
local DB_NPC_FRIENDLY = 13

_QuestieDB.questCache = {}; -- stores quest objects so they dont need to be regenerated
_QuestieDB.itemCache = {};
_QuestieDB.npcCache = {};
_QuestieDB.objectCache = {};
_QuestieDB.zoneCache = {};

function QuestieDB:Initialize()
    QuestieDBZone:ZoneCreateConversion()
    _QuestieDB:HideClassAndRaceQuests()
    _QuestieDB:DeleteGatheringNodes()

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

    local rawdata = QuestieDB.objectData[objectId];
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
    _QuestieDB.objectCache[objectId] = obj;
    return obj;
end

function QuestieDB:GetItem(itemId)
    if itemId == nil then
        return nil
    end
    if _QuestieDB.itemCache[itemId] ~= nil then
        return _QuestieDB.itemCache[itemId];
    end

    local rawdata = QuestieDB.itemData[itemId]; -- TODO: use the good item db, I need to talk to Muehe about the format, this is a temporary fix
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
    for _, v in pairs(rawdata[3]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
        local source = {};
        source.Type = "monster";
        source.Id = v;
        tinsert(item.Sources, source);
    end
    for _, v in pairs(rawdata[4]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
        local source = {};
        source.Type = "object";
        source.Id = v;
        tinsert(item.Sources, source);
    end

    _QuestieDB.itemCache[itemId] = item;
    return item
end

local function _GetColoredQuestName(self, blizzLike)
    local questName = (self.LocalizedName or self.name)
    return QuestieLib:GetColoredQuestName(self.Id, questName, self.level, Questie.db.global.enableTooltipsQuestLevel, false, blizzLike)
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

    local rawdata = QuestieDB.questData[questId];
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
        local questType, _ = GetQuestTagInfo(questId)
        return questType == 81
    end

    function QO:IsPvPQuest()
        local questType, _ = GetQuestTagInfo(questId)
        return questType == 41 or QuestieDB:IsPvPQuest(questId)
    end

    function QO:IsLevelRequirementsFulfilled(playerLevel, minLevel, maxLevel)
        return (self.level == 60 and self.requiredLevel == 1)
            or (self.level >= minLevel or Questie.db.char.lowlevel)
            and self.level <= maxLevel
            and (self.requiredLevel <= playerLevel
            or Questie.db.char.manualMinLevelOffset
            or Questie.db.char.absoluteLevelOffset)
    end

    function QO:IsDoable()
        if self.isHidden then
            return false;
        end
        if Questie.db.char.hidden[self.Id] then
            return false;
        end
        if self.nextQuestInChain then
            if Questie.db.char.complete[self.nextQuestInChain] or QuestiePlayer.currentQuestlog[self.nextQuestInChain] then
                return false
            end
        end
        -- Check if a quest which is exclusive to the current has already been completed or accepted
        -- If yes the current quest can't be accepted
        if self.ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
            for k, v in pairs(self.ExclusiveQuestGroup) do
                if Questie.db.char.complete[v] or QuestiePlayer.currentQuestlog[v] then
                    return false
                end
            end
        end
        if self.parentQuest then
            -- If the quest has a parent quest then only show it if the
            -- parent quest is in the quest log
            return self:IsParentQuestActive()
        end

        if not QuestieProfessions:HasProfessionAndSkillLevel(self.requiredSkill) then
            return false
        end

        if not QuestieReputation:HasReputation(self.requiredMinRep, self.requiredMaxRep) then
            return false
        end

        -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
        if self.preQuestGroup ~= nil and next(self.preQuestGroup) ~= nil then
            return self:IsPreQuestGroupFulfilled()
        end

        -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
        if self.preQuestSingle ~= nil and next(self.preQuestSingle) ~= nil then
            return self:IsPreQuestSingleFulfilled()
        end

        return true
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
                obj.Name = QuestieDB.npcData[v]
                if obj.Name ~= nil then
                    local name = obj.Name[QuestieDB.npcKeys.name]
                    obj.Name = string.lower(name);
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
                obj.Name = QuestieDB.objectData[v]
                if obj.Name ~= nil then
                    obj.Name = string.lower(obj.Name[1]);
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

                obj.Name = QuestieDB.itemData[obj.Id]
                if obj.Name ~= nil then
                    local name = obj.Name[QuestieDB.itemKeys.name]
                    obj.Name = string.lower(name);
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
function QuestieDB:GetCreatureLevels(quest)
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
                local item = QuestieDB:GetItem(itemObjective[1])
                if item and item.npcDrops then
                    _CollectCreatureLevels(item.npcDrops)
                end
            end
        end
    end
    return creatureLevels
end

QuestieDB.FactionGroup = UnitFactionGroup("player")

function _QuestieDB:GetSpecialNPC(npcId)
    if npcId == nil then
        return nil
    end
    local rawdata = Questie_SpecialNPCs[npcId]
    if rawdata then
        local NPC = {}
        NPC.id = npcId
        if not _QuestieDB.stream then -- bad code
            _QuestieDB.stream = QuestieStreamLib:GetStream("b89")
        end
        _QuestieDB.stream:Load(rawdata)
        NPC.name = _QuestieDB.stream:ReadTinyString()
        NPC.type = "monster"
        NPC.newFormatSpawns = {}; -- spawns should be stored like this: {{x, y, uimapid}, ...} so im creating a 2nd var to aid with moving to the new format
        NPC.spawns = {};
        local count = _QuestieDB.stream:ReadByte()
        for i=1, count do
            local x = _QuestieDB.stream:ReadShort() / 655.35
            local y = _QuestieDB.stream:ReadShort() / 655.35
            local m = _QuestieDB.stream:ReadByte() + 1400
            tinsert(NPC.newFormatSpawns, {x, y, m});

            m = QuestieDBZone:GetAreaIdByUIMapID(m)
            if m then
                if not NPC.spawns[m] then
                    NPC.spawns[m] = {};
                end
                tinsert(NPC.spawns[m], {x, y});
            end
        end
        return NPC
    end
    return nil
end

function QuestieDB:GetNPC(npcId)
    if npcId == nil then
        return nil
    end
    if(_QuestieDB.npcCache[npcId]) then
        return _QuestieDB.npcCache[npcId]
    end

    local rawdata = QuestieDB.npcData[npcId]
    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetNPC] rawdata is nil for npcID:", npcId)
        return _QuestieDB:GetSpecialNPC(npcId)
    end

    local npc = {}
    npc.type = "monster"
    npc.id = npcId
    for stringKey, intKey in pairs(QuestieDB.npcKeys) do
        npc[stringKey] = rawdata[intKey]
    end
    if npc.spawns == nil and Questie_SpecialNPCs[npcId] then -- get spawns from script spawns list
        npc.spawns = _QuestieDB:GetSpecialNPC(npcId).spawns
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

    _QuestieDB.npcCache[npcId] = npc
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

    -- in in cache return that
    if _QuestieDB.zoneCache[zoneId] then
        return _QuestieDB.zoneCache[zoneId]
    end

    local zoneQuests = {};
    local alternativeZoneID = QuestieDBZone:GetAlternativeZoneId(zoneId)
    -- loop over all quests to populate a zone
    for qid, _ in pairs(QuestieDB.questData) do
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
    local _, _, classIndex = UnitClass("player");
    local _, _, raceIndex = UnitRace("player");
    if classIndex and raceIndex then
        classIndex = math.pow(2, classIndex-1)
        raceIndex = math.pow(2, raceIndex-1)
        local questKeys = QuestieDB.questKeys
        for key, entry in pairs(QuestieDB.questData) do
            -- check requirements, set hidden flag if not met
            local requiredClasses = entry[questKeys.requiredClasses]
            if (requiredClasses) and (requiredClasses ~= 0) then
                if (bit.band(requiredClasses, classIndex) == 0) then
                    entry.hidden = true
                end
            end
            local requiredRaces = entry[questKeys.requiredRaces]
            if (requiredRaces) and (requiredRaces ~= 0) and (requiredRaces ~= 255) then
                if (bit.band(requiredRaces, raceIndex) == 0) then
                    entry.hidden = true
                end
            end
        end
    end
    Questie:Debug(DEBUG_DEVELOP, "Other class and race quests hidden");
end

local falselyMarkedPvPQuests = {
    [7161] = true,
    [7162] = true,
    [8122] = true,
    [8404] = true,
    [8405] = true,
    [8406] = true,
    [8408] = true,
}

---Checks wheather a quest is a PvP quest or not. Some PvP
--- quests are falsely marked by the Blizzard GetQuestTagInfo API
--- and need to be checked by hand
---@param questId QuestId
---@return boolean @True if the quest is in the falselyMarkedPvPQuests list, false otherwise
function QuestieDB:IsPvPQuest(questId)
    if questId ~= nil and falselyMarkedPvPQuests[questId] ~= nil then
        return true
    end
    return false
end
